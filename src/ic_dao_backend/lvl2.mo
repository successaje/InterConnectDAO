import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";

actor class DAO() = this {

    public type Member = {
        name : Text;
        age : Nat;
    };
    public type Result<A, B> = Result.Result<A, B>;
    public type HashMap<A, B> = HashMap.HashMap<A, B>;

    var members : HashMap<Principal, Member> = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);


    public shared ({ caller }) func addMember(member : Member) : async Result<(), Text> {
      switch(members.get(caller)){
        case(null){
          members.put(caller, member);
          return #ok();
        }; case(_){
          return #err("User already exists");
        }
      }
        
    };

    public shared ({ caller }) func updateMember(member : Member) : async Result<(), Text> {
      switch(members.get(caller)){
        case(null){
          return #err("You are not a member");
        }; case(_){
          members.put(caller, member);
          return #ok()
        }
      }
    };

    public shared ({ caller }) func removeMember() : async Result<(), Text> {
        switch(members.get(caller)){
        case(null){
          return #err("You are not a member");
        }; case(_){
          members.delete(caller);
          return #ok()
        }
      }
    };

    public query func getMember(p : Principal) : async Result<Member, Text> {
        switch(members.get(p)){
        case(null){
          return #err("You are not a member");
        }; case(?member){
          return #ok(member);
        }
      }
    };

    public query func getAllMembers() : async [Member] {
        return Iter.toArray(members.vals());
    };

    public query func numberOfMembers() : async Nat {
        return members.size();
    };

};