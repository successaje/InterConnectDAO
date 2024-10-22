// https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/?tag=2567882399

import Http "utilities/http";
import Account "utilities/account";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Array "mo:base/Array";

import icdao "canister:icdao";

actor class ICDAO() = this {

  let logo : Text = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"512\" height=\"512\" xml:space=\"preserve\"><g fill-rule=\"evenodd\" clip-rule=\"evenodd\"><path fill=\"#1E62D6\" d=\"M128 352c53.023 0 96-42.977 96-96h32c0 70.688-57.309 128-128 128S0 326.688 0 256c0-70.691 57.309-128 128-128 31.398 0 60.141 11.344 82.406 30.117l-.039.059c3.414 2.93 5.625 7.215 5.625 12.082 0 8.824-7.156 16-16 16-3.859 0-7.371-1.434-10.145-3.723l-.039.059C173.109 168.516 151.562 160 128 160c-53.023 0-96 42.977-96 96s42.977 96 96 96z\"/><path fill=\"#FF0083\" d=\"M352 384c-8.844 0-16-7.156-16-16s7.156-16 16-16c53.023 0 96-42.977 96-96s-42.977-96-96-96-96 42.977-96 96h-32c0-70.691 57.312-128 128-128s128 57.309 128 128c0 70.688-57.312 128-128 128zm-64-48c8.844 0 16 7.156 16 16s-7.156 16-16 16-16-7.156-16-16 7.156-16 16-16z\"/></g></svg>";

  // lvl 2
  public type Member = {
    name : Text;
    userName : Text;
    email : ?Text;
    age : ?Nat;
    joinAs : UserType;
  };

  public type UserType = { #Org; #Reg };
  public type Result<A, B> = Result.Result<A, B>;
  public type HashMap<A, B> = HashMap.HashMap<A, B>;

  var members : HashMap<Principal, Member> = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

  public shared ({ caller }) func addMember(member : Member) : async Result<(), Text> {
    switch (members.get(caller)) {
      case (null) {
        if (not (usernameChecker(member.userName))) {
          return #err("Username exists, need to be unique");
        };
        members.put(caller, member);
        return #ok();
      };
      case (_) {
        return #err("User already exists");
      };
    };
  };

  func usernameChecker(username : Text) : Bool {
    var unique = true;
    for ((i, j) in members.entries()) {
      if (j.userName == username) {
        unique := false;
      };
    };
    unique;
  };

  public shared ({ caller }) func updateMember(member : Member) : async Result<(), Text> {
    switch (members.get(caller)) {
      case (null) {
        return #err("You are not a member");
      };
      case (_) {
        members.put(caller, member);
        return #ok();
      };
    };
  };

  public shared ({ caller }) func removeMember() : async Result<(), Text> {
    switch (members.get(caller)) {
      case (null) {
        return #err("You are not a member");
      };
      case (_) {
        members.delete(caller);
        return #ok();
      };
    };
  };

  public query func getMember(p : Principal) : async Result<Member, Text> {
    switch (members.get(p)) {
      case (null) {
        return #err("You are not a member");
      };
      case (?member) {
        return #ok(member);
      };
    };
  };

  func isDAOMember(account : Principal) : Bool {
    switch (members.get(account)) {
      case (null) {
        return false;
      };
      case (?members) {
        return true;
      };
    };
  };

  public query func getAllMembers() : async [Member] {
    return Iter.toArray(members.vals());
  };

  public query func getOrgMembers() : async [Member] {
    var buffer = Buffer.Buffer<Member>(0);
    for ((key, vals) in members.entries()) {
      if (vals.joinAs == #Org) {
        buffer.add(vals);
      };
    };
    buffer.toArray();
  };

  public query func isOrg(principal : Principal) : async Bool {
    var isorg = false;
    for ((key, vals) in members.entries()) {
      if (key == principal) {
        if (vals.joinAs == #Org) {
          isorg := true;
        };
      };
    };
    isorg;
  };

  public query func getRegMembers() : async [Member] {
    var buffer = Buffer.Buffer<Member>(0);
    for ((key, vals) in members.entries()) {
      if (vals.joinAs == #Reg) {
        buffer.add(vals);
      };
    };
    buffer.toArray();
  };

  public query func numberOfMembers() : async Nat {
    return members.size();
  };

  /////////////////
  //    Tokens   //
  /////////////////

  public func mint(to : Principal, value : Nat) : async Bool {
    await icdao.mint(to, value);
  };

  //////////////////////////
  //  Proposals and votes //
  //////////////////////////

  func hasEnoughToken(owner : Principal, n : Nat) : async Bool {
    let balance : Nat = await icdao.balanceOf(owner);
    if (n > balance) {
      return false;
    };
    return true;

  };

  func _burnTokens(caller : Principal, amount : Nat) : async Bool {
    await icdao.burn(caller, amount);
  };

  public type Status = {
    #Open;
    #Accepted;
    #Rejected;
  };

  public type Proposal = {
    id : Nat;
    status : Status;
    manifest : Text;
    votes : Int;
    voters : [Principal];
    proposal_type : UserType;
  };

  var nextProposalId : Nat = 0;

  public type CreateProposalOk = Nat;

  let proposals = TrieMap.TrieMap<Nat, Proposal>(Nat.equal, Hash.hash);

  public type CreateProposalErr = {
    #NotDAOMember;
    #NotEnoughTokens;
  };

  public type CreateProposalResult = Result<CreateProposalOk, CreateProposalErr>;

  public type VoteOk = {
    #ProposalAccepted;
    #ProposalRefused;
    #ProposalOpen;
  };

  public type VoteErr = {
    #NotDAOMember;
    #ProposalNotFound;
    #NotEnoughTokens;
    #AlreadyVoted;
    #ProposalEnded;
  };

  public type voteResult = Result<VoteOk, VoteErr>;

  public shared ({ caller }) func createProposal(manifest : Text) : async CreateProposalResult {

    if (not (isDAOMember(caller))) {
      return #err(#NotDAOMember);
    };

    if (not (await hasEnoughToken(caller, 2))) {
      return #err(#NotEnoughTokens);
    };

    let pid = nextProposalId;

    var proposal : Proposal = {
      id = pid;
      status = #Open;
      manifest;
      votes = 0;
      voters = [];
      proposal_type = #Reg;
    };

    if ((await isOrg(caller))) {
      proposal := {
        id = pid;
        status = #Open;
        manifest;
        votes = 0;
        voters = [];
        proposal_type = #Org;
      };
    };

    proposals.put(pid, proposal);
    if (await _burnTokens(caller, 2)) {
      nextProposalId += 1;
    };
    return #ok(pid);

  };

  public query func getProposal(id : Nat) : async ?Proposal {
    return proposals.get(id);
  };

  func _isProposalOpen(proposal : Proposal) : Bool {
    switch (proposal.status) {
      case (#Open) {
        return true;
      };
      case (_) {
        return false;
      };
    };
  };

  func _hasAlreadyVoted(p : Principal, proposal : Proposal) : Bool {
    for (voter in proposal.voters.vals()) {
      if (voter == p) {
        return true;
      };
    };
    return false;
  };

  public shared ({ caller }) func vote(id : Nat, vote : Bool) : async voteResult {

    if (not (isDAOMember(caller))) {
      return #err(#NotDAOMember);
    };

    if (not (await hasEnoughToken(caller, 1))) {
      return #err(#NotEnoughTokens);
    };

    switch (proposals.get(id)) {
      case (null) {
        return #err(#ProposalNotFound);
      };
      case (?proposal) {
        if (not (_isProposalOpen(proposal))) {
          return #err(#ProposalEnded);
        };
        if (_hasAlreadyVoted(caller, proposal)) {
          return #err(#AlreadyVoted);
        };

        let newVotes = switch (vote) {
          case (true) {
            proposal.votes + 1;
          };
          case (false) {
            proposal.votes - 1;
          };
        };

        let newStatus = switch (newVotes) {
          case (10) {
            #Accepted;
          };
          case (-10) {
            #Rejected;
          };
          case (_) {
            #Open;
          };
        };

        let newVoters = Array.append<Principal>(proposal.voters, [caller]);

        let newProposal : Proposal = {
          id = proposal.id;
          status = newStatus;
          manifest = proposal.manifest;
          votes = newVotes;
          voters = newVoters;
          proposal_type = proposal.proposal_type;
        };

        proposals.put(proposal.id, newProposal);

        let returnValue = switch (newStatus) {
          case (#Open) {
            #ProposalOpen;
          };
          case (#Accepted) {
            #ProposalAccepted;
          };
          case (#Rejected) {
            #ProposalRefused;
          };
        };
        return #ok(returnValue);
      };
    };
  };

  public shared query ({ caller }) func whoami() : async Principal {
    caller;
  };

};
