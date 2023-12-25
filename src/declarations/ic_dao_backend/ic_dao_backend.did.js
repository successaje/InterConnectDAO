export const idlFactory = ({ IDL }) => {
  const UserType = IDL.Variant({ 'Org' : IDL.Null, 'Reg' : IDL.Null });
  const Member = IDL.Record({
    'age' : IDL.Opt(IDL.Nat),
    'userName' : IDL.Text,
    'name' : IDL.Text,
    'email' : IDL.Opt(IDL.Text),
    'joinAs' : UserType,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Subaccount = IDL.Vec(IDL.Nat8);
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(Subaccount),
  });
  const CreateProposalOk = IDL.Nat;
  const CreateProposalErr = IDL.Variant({
    'NotDAOMember' : IDL.Null,
    'NotEnoughTokens' : IDL.Null,
  });
  const CreateProposalResult = IDL.Variant({
    'ok' : CreateProposalOk,
    'err' : CreateProposalErr,
  });
  const Result_1 = IDL.Variant({ 'ok' : Member, 'err' : IDL.Text });
  const Status = IDL.Variant({
    'Open' : IDL.Null,
    'Rejected' : IDL.Null,
    'Accepted' : IDL.Null,
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'status' : Status,
    'votes' : IDL.Int,
    'voters' : IDL.Vec(IDL.Principal),
    'manifest' : IDL.Text,
    'proposal_type' : UserType,
  });
  const DAOStats = IDL.Record({
    'member' : IDL.Vec(IDL.Text),
    'numberOfMembers' : IDL.Nat,
    'logo' : IDL.Text,
    'name' : IDL.Text,
    'manifesto' : IDL.Text,
    'goals' : IDL.Vec(IDL.Text),
  });
  const HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
  const HttpRequest = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
  });
  const StreamingCallbackToken = IDL.Record({
    'key' : IDL.Text,
    'index' : IDL.Nat,
    'content_encoding' : IDL.Text,
  });
  const StreamingCallbackResponse = IDL.Record({
    'token' : IDL.Opt(StreamingCallbackToken),
    'body' : IDL.Vec(IDL.Nat8),
  });
  const StreamingCallback = IDL.Func(
      [StreamingCallbackToken],
      [StreamingCallbackResponse],
      ['query'],
    );
  const StreamingStrategy = IDL.Variant({
    'Callback' : IDL.Record({
      'token' : StreamingCallbackToken,
      'callback' : StreamingCallback,
    }),
  });
  const HttpResponse = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
    'streaming_strategy' : IDL.Opt(StreamingStrategy),
    'status_code' : IDL.Nat16,
  });
  const VoteOk = IDL.Variant({
    'ProposalOpen' : IDL.Null,
    'ProposalRefused' : IDL.Null,
    'ProposalAccepted' : IDL.Null,
  });
  const VoteErr = IDL.Variant({
    'AlreadyVoted' : IDL.Null,
    'ProposalEnded' : IDL.Null,
    'ProposalNotFound' : IDL.Null,
    'NotDAOMember' : IDL.Null,
    'NotEnoughTokens' : IDL.Null,
  });
  const voteResult = IDL.Variant({ 'ok' : VoteOk, 'err' : VoteErr });
  const ICDAO = IDL.Service({
    '_balance' : IDL.Func([IDL.Principal], [IDL.Nat], []),
    'addMember' : IDL.Func([Member], [Result], []),
    'balanceOf' : IDL.Func([Account], [IDL.Nat], ['query']),
    'createProposal' : IDL.Func([IDL.Text], [CreateProposalResult], []),
    'getAllMembers' : IDL.Func([], [IDL.Vec(Member)], ['query']),
    'getMember' : IDL.Func([IDL.Principal], [Result_1], ['query']),
    'getOrgMembers' : IDL.Func([], [IDL.Vec(Member)], ['query']),
    'getProposal' : IDL.Func([IDL.Nat], [IDL.Opt(Proposal)], ['query']),
    'getRegMembers' : IDL.Func([], [IDL.Vec(Member)], ['query']),
    'getStats' : IDL.Func([], [DAOStats], ['query']),
    'http_request' : IDL.Func([HttpRequest], [HttpResponse], ['query']),
    'isOrg' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'mint' : IDL.Func([IDL.Principal, IDL.Nat], [], []),
    'numberOfMembers' : IDL.Func([], [IDL.Nat], ['query']),
    'removeMember' : IDL.Func([], [Result], []),
    'tokenName' : IDL.Func([], [IDL.Text], ['query']),
    'tokenSymbol' : IDL.Func([], [IDL.Text], ['query']),
    'totalSupply' : IDL.Func([], [IDL.Nat], ['query']),
    'transfer' : IDL.Func([Account, Account, IDL.Nat], [Result], []),
    'updateMember' : IDL.Func([Member], [Result], []),
    'vote' : IDL.Func([IDL.Nat, IDL.Bool], [voteResult], []),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
  return ICDAO;
};
export const init = ({ IDL }) => { return []; };
