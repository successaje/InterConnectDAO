import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export type CreateProposalErr = { 'NotDAOMember' : null } |
  { 'NotEnoughTokens' : null };
export type CreateProposalOk = bigint;
export type CreateProposalResult = { 'ok' : CreateProposalOk } |
  { 'err' : CreateProposalErr };
export interface DAO {
  'addMember' : ActorMethod<[Member], Result>,
  'balanceOf' : ActorMethod<[Account], bigint>,
  'createProposal' : ActorMethod<[string], CreateProposalResult>,
  'getAllMembers' : ActorMethod<[], Array<Member>>,
  'getMember' : ActorMethod<[Principal], Result_1>,
  'getProposal' : ActorMethod<[bigint], [] | [Proposal]>,
  'getStats' : ActorMethod<[], DAOStats>,
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'mint' : ActorMethod<[Principal, bigint], undefined>,
  'numberOfMembers' : ActorMethod<[], bigint>,
  'removeMember' : ActorMethod<[], Result>,
  'tokenName' : ActorMethod<[], string>,
  'tokenSymbol' : ActorMethod<[], string>,
  'totalSupply' : ActorMethod<[], bigint>,
  'transfer' : ActorMethod<[Account, Account, bigint], Result>,
  'updateMember' : ActorMethod<[Member], Result>,
  'vote' : ActorMethod<[bigint, boolean], voteResult>,
}
export interface DAOStats {
  'member' : Array<string>,
  'numberOfMembers' : bigint,
  'logo' : string,
  'name' : string,
  'manifesto' : string,
  'goals' : Array<string>,
}
export type HeaderField = [string, string];
export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Uint8Array,
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Uint8Array,
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [StreamingStrategy],
  'status_code' : number,
}
export interface Member { 'age' : bigint, 'name' : string }
export interface Proposal {
  'id' : bigint,
  'status' : Status,
  'votes' : bigint,
  'voters' : Array<Principal>,
  'manifest' : string,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : Member } |
  { 'err' : string };
export type Status = { 'Open' : null } |
  { 'Rejected' : null } |
  { 'Accepted' : null };
export type StreamingCallback = ActorMethod<
  [StreamingCallbackToken],
  StreamingCallbackResponse
>;
export interface StreamingCallbackResponse {
  'token' : [] | [StreamingCallbackToken],
  'body' : Uint8Array,
}
export interface StreamingCallbackToken {
  'key' : string,
  'index' : bigint,
  'content_encoding' : string,
}
export type StreamingStrategy = {
    'Callback' : {
      'token' : StreamingCallbackToken,
      'callback' : StreamingCallback,
    }
  };
export type Subaccount = Uint8Array;
export type VoteErr = { 'AlreadyVoted' : null } |
  { 'ProposalEnded' : null } |
  { 'ProposalNotFound' : null } |
  { 'NotDAOMember' : null } |
  { 'NotEnoughTokens' : null };
export type VoteOk = { 'ProposalOpen' : null } |
  { 'ProposalRefused' : null } |
  { 'ProposalAccepted' : null };
export type voteResult = { 'ok' : VoteOk } |
  { 'err' : VoteErr };
export interface _SERVICE extends DAO {}
