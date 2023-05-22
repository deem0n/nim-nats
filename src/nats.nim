when defined(Windows):
  const dynlibnats = "nats.dll"

when defined(Linux):
  const dynlibnats = "libnats.so"

when defined(MacOSX):
  const dynlibnats = "libnats.dylib"

import strutils
const sourcePath = currentSourcePath().split({'\\', '/'})[0..^2].join("/")
{.passC: "-I\"" & sourcePath & "/src\"".}
type
  natsConnStatus* {.size: sizeof(cint).} = enum
    NATS_CONN_STATUS_DISCONNECTED = 0, NATS_CONN_STATUS_CONNECTING,
    NATS_CONN_STATUS_CONNECTED, NATS_CONN_STATUS_CLOSED,
    NATS_CONN_STATUS_RECONNECTING, NATS_CONN_STATUS_DRAINING_SUBS,
    NATS_CONN_STATUS_DRAINING_PUBS
  natsStatus* {.size: sizeof(cint).} = enum
    NATS_OK = 0, NATS_ERR, NATS_PROTOCOL_ERROR, NATS_IO_ERROR, NATS_LINE_TOO_LONG,
    NATS_CONNECTION_CLOSED, NATS_NO_SERVER, NATS_STALE_CONNECTION,
    NATS_SECURE_CONNECTION_WANTED, NATS_SECURE_CONNECTION_REQUIRED,
    NATS_CONNECTION_DISCONNECTED, NATS_CONNECTION_AUTH_FAILED, NATS_NOT_PERMITTED,
    NATS_NOT_FOUND, NATS_ADDRESS_MISSING, NATS_INVALID_SUBJECT, NATS_INVALID_ARG,
    NATS_INVALID_SUBSCRIPTION, NATS_INVALID_TIMEOUT, NATS_ILLEGAL_STATE,
    NATS_SLOW_CONSUMER, NATS_MAX_PAYLOAD, NATS_MAX_DELIVERED_MSGS,
    NATS_INSUFFICIENT_BUFFER, NATS_NO_MEMORY, NATS_SYS_ERROR, NATS_TIMEOUT,
    NATS_FAILED_TO_INITIALIZE, NATS_NOT_INITIALIZED, NATS_SSL_ERROR,
    NATS_NO_SERVER_SUPPORT, NATS_NOT_YET_CONNECTED, NATS_DRAINING,
    NATS_INVALID_QUEUE_NAME, NATS_NO_RESPONDERS, NATS_MISMATCH,
    NATS_MISSED_HEARTBEAT



type
  natsConnection* {.bycopy.} = object

  natsStatistics* {.bycopy.} = object

  natsSubscription* {.bycopy.} = object

  natsMsg* {.bycopy.} = object

  natsOptions* {.bycopy.} = object

  natsSock* = cint
  natsInbox* = char
  natsMsgList* {.bycopy.} = object
    Msgs*: ptr ptr natsMsg
    Count*: cint


  natsMsgHandler* = proc (nc: ptr natsConnection; sub: ptr natsSubscription;
                       msg: ptr natsMsg; closure: pointer)
  natsConnectionHandler* = proc (nc: ptr natsConnection; closure: pointer)
  natsErrHandler* = proc (nc: ptr natsConnection; subscription: ptr natsSubscription;
                       err: natsStatus; closure: pointer)
  natsEvLoop_Attach* = proc (userData: ptr pointer; loop: pointer;
                          nc: ptr natsConnection; socket: natsSock): natsStatus
  natsEvLoop_ReadAddRemove* = proc (userData: pointer; add: bool): natsStatus
  natsEvLoop_WriteAddRemove* = proc (userData: pointer; add: bool): natsStatus
  natsEvLoop_Detach* = proc (userData: pointer): natsStatus
  natsUserJWTHandler* = proc (userJWT: cstringArray; customErrTxt: cstringArray;
                           closure: pointer): natsStatus
  natsSignatureHandler* = proc (customErrTxt: cstringArray;
                             signature: ptr ptr cuchar; signatureLength: ptr cint;
                             nonce: cstring; closure: pointer): natsStatus
  natsTokenHandler* = proc (closure: pointer): cstring
  natsOnCompleteCB* = proc (closure: pointer)
  natsCustomReconnectDelayHandler* = proc (nc: ptr natsConnection; attempts: cint;
                                        closure: pointer): int64

proc nats_Open*(lockSpinCount: int64): natsStatus {.importc: "nats_Open",
    dynlib: dynlibNats.}
proc nats_GetVersion*(): cstring {.importc: "nats_GetVersion", dynlib: dynlibNats.}
proc nats_GetVersionNumber*(): uint32 {.importc: "nats_GetVersionNumber",
                                     dynlib: dynlibNats.}
proc nats_CheckCompatibilityImpl*(reqVerNumber: uint32; verNumber: uint32;
                                 verString: cstring): bool {.
    importc: "nats_CheckCompatibilityImpl", dynlib: dynlibNats.}
proc nats_Now*(): int64 {.importc: "nats_Now", dynlib: dynlibNats.}
proc nats_NowInNanoSeconds*(): int64 {.importc: "nats_NowInNanoSeconds",
                                    dynlib: dynlibNats.}
proc nats_Sleep*(sleepTime: int64) {.importc: "nats_Sleep", dynlib: dynlibNats.}
proc nats_GetLastError*(status: ptr natsStatus): cstring {.
    importc: "nats_GetLastError", dynlib: dynlibNats.}
proc nats_GetLastErrorStack*(buffer: cstring; bufLen: csize_t): natsStatus {.
    importc: "nats_GetLastErrorStack", dynlib: dynlibNats.}
proc nats_PrintLastErrorStack*(file: ptr FILE) {.
    importc: "nats_PrintLastErrorStack", dynlib: dynlibNats.}
proc nats_SetMessageDeliveryPoolSize*(max: cint): natsStatus {.
    importc: "nats_SetMessageDeliveryPoolSize", dynlib: dynlibNats.}
proc nats_ReleaseThreadMemory*() {.importc: "nats_ReleaseThreadMemory",
                                 dynlib: dynlibNats.}
proc nats_Sign*(encodedSeed: cstring; input: cstring; signature: ptr ptr cuchar;
               signatureLength: ptr cint): natsStatus {.importc: "nats_Sign",
    dynlib: dynlibNats.}
proc nats_Close*() {.importc: "nats_Close", dynlib: dynlibNats.}
proc nats_CloseAndWait*(timeout: int64): natsStatus {.importc: "nats_CloseAndWait",
    dynlib: dynlibNats.}
proc natsStatus_GetText*(s: natsStatus): cstring {.importc: "natsStatus_GetText",
    dynlib: dynlibNats.}
proc natsStatistics_Create*(newStats: ptr ptr natsStatistics): natsStatus {.
    importc: "natsStatistics_Create", dynlib: dynlibNats.}
proc natsStatistics_GetCounts*(stats: ptr natsStatistics; inMsgs: ptr uint64;
                              inBytes: ptr uint64; outMsgs: ptr uint64;
                              outBytes: ptr uint64; reconnects: ptr uint64): natsStatus {.
    importc: "natsStatistics_GetCounts", dynlib: dynlibNats.}
proc natsStatistics_Destroy*(stats: ptr natsStatistics) {.
    importc: "natsStatistics_Destroy", dynlib: dynlibNats.}
proc natsOptions_Create*(newOpts: ptr ptr natsOptions): natsStatus {.
    importc: "natsOptions_Create", dynlib: dynlibNats.}
proc natsOptions_SetURL*(opts: ptr natsOptions; url: cstring): natsStatus {.
    importc: "natsOptions_SetURL", dynlib: dynlibNats.}
proc natsOptions_SetServers*(opts: ptr natsOptions; servers: cstringArray;
                            serversCount: cint): natsStatus {.
    importc: "natsOptions_SetServers", dynlib: dynlibNats.}
proc natsOptions_SetUserInfo*(opts: ptr natsOptions; user: cstring; password: cstring): natsStatus {.
    importc: "natsOptions_SetUserInfo", dynlib: dynlibNats.}
proc natsOptions_SetToken*(opts: ptr natsOptions; token: cstring): natsStatus {.
    importc: "natsOptions_SetToken", dynlib: dynlibNats.}
proc natsOptions_SetTokenHandler*(opts: ptr natsOptions; tokenCb: natsTokenHandler;
                                 closure: pointer): natsStatus {.
    importc: "natsOptions_SetTokenHandler", dynlib: dynlibNats.}
proc natsOptions_SetNoRandomize*(opts: ptr natsOptions; noRandomize: bool): natsStatus {.
    importc: "natsOptions_SetNoRandomize", dynlib: dynlibNats.}
proc natsOptions_SetTimeout*(opts: ptr natsOptions; timeout: int64): natsStatus {.
    importc: "natsOptions_SetTimeout", dynlib: dynlibNats.}
proc natsOptions_SetName*(opts: ptr natsOptions; name: cstring): natsStatus {.
    importc: "natsOptions_SetName", dynlib: dynlibNats.}
proc natsOptions_SetSecure*(opts: ptr natsOptions; secure: bool): natsStatus {.
    importc: "natsOptions_SetSecure", dynlib: dynlibNats.}
proc natsOptions_LoadCATrustedCertificates*(opts: ptr natsOptions; fileName: cstring): natsStatus {.
    importc: "natsOptions_LoadCATrustedCertificates", dynlib: dynlibNats.}
proc natsOptions_SetCATrustedCertificates*(opts: ptr natsOptions;
    certificates: cstring): natsStatus {.importc: "natsOptions_SetCATrustedCertificates",
                                      dynlib: dynlibNats.}
proc natsOptions_LoadCertificatesChain*(opts: ptr natsOptions;
                                       certsFileName: cstring;
                                       keyFileName: cstring): natsStatus {.
    importc: "natsOptions_LoadCertificatesChain", dynlib: dynlibNats.}
proc natsOptions_SetCertificatesChain*(opts: ptr natsOptions; cert: cstring;
                                      key: cstring): natsStatus {.
    importc: "natsOptions_SetCertificatesChain", dynlib: dynlibNats.}
proc natsOptions_SetCiphers*(opts: ptr natsOptions; ciphers: cstring): natsStatus {.
    importc: "natsOptions_SetCiphers", dynlib: dynlibNats.}
proc natsOptions_SetCipherSuites*(opts: ptr natsOptions; ciphers: cstring): natsStatus {.
    importc: "natsOptions_SetCipherSuites", dynlib: dynlibNats.}
proc natsOptions_SetExpectedHostname*(opts: ptr natsOptions; hostname: cstring): natsStatus {.
    importc: "natsOptions_SetExpectedHostname", dynlib: dynlibNats.}
proc natsOptions_SkipServerVerification*(opts: ptr natsOptions; skip: bool): natsStatus {.
    importc: "natsOptions_SkipServerVerification", dynlib: dynlibNats.}
proc natsOptions_SetVerbose*(opts: ptr natsOptions; verbose: bool): natsStatus {.
    importc: "natsOptions_SetVerbose", dynlib: dynlibNats.}
proc natsOptions_SetPedantic*(opts: ptr natsOptions; pedantic: bool): natsStatus {.
    importc: "natsOptions_SetPedantic", dynlib: dynlibNats.}
proc natsOptions_SetPingInterval*(opts: ptr natsOptions; interval: int64): natsStatus {.
    importc: "natsOptions_SetPingInterval", dynlib: dynlibNats.}
proc natsOptions_SetMaxPingsOut*(opts: ptr natsOptions; maxPingsOut: cint): natsStatus {.
    importc: "natsOptions_SetMaxPingsOut", dynlib: dynlibNats.}
proc natsOptions_SetIOBufSize*(opts: ptr natsOptions; ioBufSize: cint): natsStatus {.
    importc: "natsOptions_SetIOBufSize", dynlib: dynlibNats.}
proc natsOptions_SetAllowReconnect*(opts: ptr natsOptions; allow: bool): natsStatus {.
    importc: "natsOptions_SetAllowReconnect", dynlib: dynlibNats.}
proc natsOptions_SetMaxReconnect*(opts: ptr natsOptions; maxReconnect: cint): natsStatus {.
    importc: "natsOptions_SetMaxReconnect", dynlib: dynlibNats.}
proc natsOptions_SetReconnectWait*(opts: ptr natsOptions; reconnectWait: int64): natsStatus {.
    importc: "natsOptions_SetReconnectWait", dynlib: dynlibNats.}
proc natsOptions_SetReconnectJitter*(opts: ptr natsOptions; jitter: int64;
                                    jitterTLS: int64): natsStatus {.
    importc: "natsOptions_SetReconnectJitter", dynlib: dynlibNats.}
proc natsOptions_SetCustomReconnectDelay*(opts: ptr natsOptions;
    cb: natsCustomReconnectDelayHandler; closure: pointer): natsStatus {.
    importc: "natsOptions_SetCustomReconnectDelay", dynlib: dynlibNats.}
proc natsOptions_SetReconnectBufSize*(opts: ptr natsOptions; reconnectBufSize: cint): natsStatus {.
    importc: "natsOptions_SetReconnectBufSize", dynlib: dynlibNats.}
proc natsOptions_SetMaxPendingMsgs*(opts: ptr natsOptions; maxPending: cint): natsStatus {.
    importc: "natsOptions_SetMaxPendingMsgs", dynlib: dynlibNats.}
proc natsOptions_SetErrorHandler*(opts: ptr natsOptions; errHandler: natsErrHandler;
                                 closure: pointer): natsStatus {.
    importc: "natsOptions_SetErrorHandler", dynlib: dynlibNats.}
proc natsOptions_SetClosedCB*(opts: ptr natsOptions;
                             closedCb: natsConnectionHandler; closure: pointer): natsStatus {.
    importc: "natsOptions_SetClosedCB", dynlib: dynlibNats.}
proc natsOptions_SetDisconnectedCB*(opts: ptr natsOptions;
                                   disconnectedCb: natsConnectionHandler;
                                   closure: pointer): natsStatus {.
    importc: "natsOptions_SetDisconnectedCB", dynlib: dynlibNats.}
proc natsOptions_SetReconnectedCB*(opts: ptr natsOptions;
                                  reconnectedCb: natsConnectionHandler;
                                  closure: pointer): natsStatus {.
    importc: "natsOptions_SetReconnectedCB", dynlib: dynlibNats.}
proc natsOptions_SetDiscoveredServersCB*(opts: ptr natsOptions; discoveredServersCb: natsConnectionHandler;
                                        closure: pointer): natsStatus {.
    importc: "natsOptions_SetDiscoveredServersCB", dynlib: dynlibNats.}
proc natsOptions_SetIgnoreDiscoveredServers*(opts: ptr natsOptions; ignore: bool): natsStatus {.
    importc: "natsOptions_SetIgnoreDiscoveredServers", dynlib: dynlibNats.}
proc natsOptions_SetLameDuckModeCB*(opts: ptr natsOptions;
                                   lameDuckCb: natsConnectionHandler;
                                   closure: pointer): natsStatus {.
    importc: "natsOptions_SetLameDuckModeCB", dynlib: dynlibNats.}
proc natsOptions_SetEventLoop*(opts: ptr natsOptions; loop: pointer;
                              attachCb: natsEvLoop_Attach;
                              readCb: natsEvLoop_ReadAddRemove;
                              writeCb: natsEvLoop_WriteAddRemove;
                              detachCb: natsEvLoop_Detach): natsStatus {.
    importc: "natsOptions_SetEventLoop", dynlib: dynlibNats.}
proc natsOptions_UseGlobalMessageDelivery*(opts: ptr natsOptions; global: bool): natsStatus {.
    importc: "natsOptions_UseGlobalMessageDelivery", dynlib: dynlibNats.}
proc natsOptions_IPResolutionOrder*(opts: ptr natsOptions; order: cint): natsStatus {.
    importc: "natsOptions_IPResolutionOrder", dynlib: dynlibNats.}
proc natsOptions_SetSendAsap*(opts: ptr natsOptions; sendAsap: bool): natsStatus {.
    importc: "natsOptions_SetSendAsap", dynlib: dynlibNats.}
proc natsOptions_UseOldRequestStyle*(opts: ptr natsOptions; useOldStyle: bool): natsStatus {.
    importc: "natsOptions_UseOldRequestStyle", dynlib: dynlibNats.}
proc natsOptions_SetFailRequestsOnDisconnect*(opts: ptr natsOptions;
    failRequests: bool): natsStatus {.importc: "natsOptions_SetFailRequestsOnDisconnect",
                                    dynlib: dynlibNats.}
proc natsOptions_SetNoEcho*(opts: ptr natsOptions; noEcho: bool): natsStatus {.
    importc: "natsOptions_SetNoEcho", dynlib: dynlibNats.}
proc natsOptions_SetRetryOnFailedConnect*(opts: ptr natsOptions; retry: bool;
    connectedCb: natsConnectionHandler; closure: pointer): natsStatus {.
    importc: "natsOptions_SetRetryOnFailedConnect", dynlib: dynlibNats.}
proc natsOptions_SetUserCredentialsCallbacks*(opts: ptr natsOptions;
    ujwtCB: natsUserJWTHandler; ujwtClosure: pointer; sigCB: natsSignatureHandler;
    sigClosure: pointer): natsStatus {.importc: "natsOptions_SetUserCredentialsCallbacks",
                                    dynlib: dynlibNats.}
proc natsOptions_SetUserCredentialsFromFiles*(opts: ptr natsOptions;
    userOrChainedFile: cstring; seedFile: cstring): natsStatus {.
    importc: "natsOptions_SetUserCredentialsFromFiles", dynlib: dynlibNats.}
proc natsOptions_SetUserCredentialsFromMemory*(opts: ptr natsOptions;
    jwtAndSeedContent: cstring): natsStatus {.
    importc: "natsOptions_SetUserCredentialsFromMemory", dynlib: dynlibNats.}
proc natsOptions_SetNKey*(opts: ptr natsOptions; pubKey: cstring;
                         sigCB: natsSignatureHandler; sigClosure: pointer): natsStatus {.
    importc: "natsOptions_SetNKey", dynlib: dynlibNats.}
proc natsOptions_SetNKeyFromSeed*(opts: ptr natsOptions; pubKey: cstring;
                                 seedFile: cstring): natsStatus {.
    importc: "natsOptions_SetNKeyFromSeed", dynlib: dynlibNats.}
proc natsOptions_SetWriteDeadline*(opts: ptr natsOptions; deadline: int64): natsStatus {.
    importc: "natsOptions_SetWriteDeadline", dynlib: dynlibNats.}
proc natsOptions_DisableNoResponders*(opts: ptr natsOptions; disabled: bool): natsStatus {.
    importc: "natsOptions_DisableNoResponders", dynlib: dynlibNats.}
proc natsOptions_SetCustomInboxPrefix*(opts: ptr natsOptions; inboxPrefix: cstring): natsStatus {.
    importc: "natsOptions_SetCustomInboxPrefix", dynlib: dynlibNats.}
proc natsOptions_SetMessageBufferPadding*(opts: ptr natsOptions; paddingSize: cint): natsStatus {.
    importc: "natsOptions_SetMessageBufferPadding", dynlib: dynlibNats.}
proc natsOptions_Destroy*(opts: ptr natsOptions) {.importc: "natsOptions_Destroy",
    dynlib: dynlibNats.}
proc natsInbox_Create*(newInbox: ptr ptr natsInbox): natsStatus {.
    importc: "natsInbox_Create", dynlib: dynlibNats.}
proc natsInbox_Destroy*(inbox: ptr natsInbox) {.importc: "natsInbox_Destroy",
    dynlib: dynlibNats.}
proc natsMsgList_Destroy*(list: ptr natsMsgList) {.importc: "natsMsgList_Destroy",
    dynlib: dynlibNats.}
proc natsMsg_Create*(newMsg: ptr ptr natsMsg; subj: cstring; reply: cstring;
                    data: cstring; dataLen: cint): natsStatus {.
    importc: "natsMsg_Create", dynlib: dynlibNats.}
proc natsMsg_GetSubject*(msg: ptr natsMsg): cstring {.importc: "natsMsg_GetSubject",
    dynlib: dynlibNats.}
proc natsMsg_GetReply*(msg: ptr natsMsg): cstring {.importc: "natsMsg_GetReply",
    dynlib: dynlibNats.}
proc natsMsg_GetData*(msg: ptr natsMsg): cstring {.importc: "natsMsg_GetData",
    dynlib: dynlibNats.}
proc natsMsg_GetDataLength*(msg: ptr natsMsg): cint {.
    importc: "natsMsg_GetDataLength", dynlib: dynlibNats.}
proc natsMsgHeader_Set*(msg: ptr natsMsg; key: cstring; value: cstring): natsStatus {.
    importc: "natsMsgHeader_Set", dynlib: dynlibNats.}
proc natsMsgHeader_Add*(msg: ptr natsMsg; key: cstring; value: cstring): natsStatus {.
    importc: "natsMsgHeader_Add", dynlib: dynlibNats.}
proc natsMsgHeader_Get*(msg: ptr natsMsg; key: cstring; value: cstringArray): natsStatus {.
    importc: "natsMsgHeader_Get", dynlib: dynlibNats.}
proc natsMsgHeader_Values*(msg: ptr natsMsg; key: cstring; values: ptr cstringArray;
                          count: ptr cint): natsStatus {.
    importc: "natsMsgHeader_Values", dynlib: dynlibNats.}
proc natsMsgHeader_Keys*(msg: ptr natsMsg; keys: ptr cstringArray; count: ptr cint): natsStatus {.
    importc: "natsMsgHeader_Keys", dynlib: dynlibNats.}
proc natsMsgHeader_Delete*(msg: ptr natsMsg; key: cstring): natsStatus {.
    importc: "natsMsgHeader_Delete", dynlib: dynlibNats.}
proc natsMsg_IsNoResponders*(msg: ptr natsMsg): bool {.
    importc: "natsMsg_IsNoResponders", dynlib: dynlibNats.}
proc natsMsg_Destroy*(msg: ptr natsMsg) {.importc: "natsMsg_Destroy",
                                      dynlib: dynlibNats.}
proc natsConnection_Connect*(nc: ptr ptr natsConnection; options: ptr natsOptions): natsStatus {.
    importc: "natsConnection_Connect", dynlib: dynlibNats.}
proc natsConnection_ProcessReadEvent*(nc: ptr natsConnection) {.
    importc: "natsConnection_ProcessReadEvent", dynlib: dynlibNats.}
proc natsConnection_ProcessWriteEvent*(nc: ptr natsConnection) {.
    importc: "natsConnection_ProcessWriteEvent", dynlib: dynlibNats.}
proc natsConnection_ConnectTo*(nc: ptr ptr natsConnection; urls: cstring): natsStatus {.
    importc: "natsConnection_ConnectTo", dynlib: dynlibNats.}
proc natsConnection_IsClosed*(nc: ptr natsConnection): bool {.
    importc: "natsConnection_IsClosed", dynlib: dynlibNats.}
proc natsConnection_IsReconnecting*(nc: ptr natsConnection): bool {.
    importc: "natsConnection_IsReconnecting", dynlib: dynlibNats.}
proc natsConnection_IsDraining*(nc: ptr natsConnection): bool {.
    importc: "natsConnection_IsDraining", dynlib: dynlibNats.}
proc natsConnection_Status*(nc: ptr natsConnection): natsConnStatus {.
    importc: "natsConnection_Status", dynlib: dynlibNats.}
proc natsConnection_Buffered*(nc: ptr natsConnection): cint {.
    importc: "natsConnection_Buffered", dynlib: dynlibNats.}
proc natsConnection_Flush*(nc: ptr natsConnection): natsStatus {.
    importc: "natsConnection_Flush", dynlib: dynlibNats.}
proc natsConnection_FlushTimeout*(nc: ptr natsConnection; timeout: int64): natsStatus {.
    importc: "natsConnection_FlushTimeout", dynlib: dynlibNats.}
proc natsConnection_GetMaxPayload*(nc: ptr natsConnection): int64 {.
    importc: "natsConnection_GetMaxPayload", dynlib: dynlibNats.}
proc natsConnection_GetStats*(nc: ptr natsConnection; stats: ptr natsStatistics): natsStatus {.
    importc: "natsConnection_GetStats", dynlib: dynlibNats.}
proc natsConnection_GetConnectedUrl*(nc: ptr natsConnection; buffer: cstring;
                                    bufferSize: csize_t): natsStatus {.
    importc: "natsConnection_GetConnectedUrl", dynlib: dynlibNats.}
proc natsConnection_GetConnectedServerId*(nc: ptr natsConnection; buffer: cstring;
    bufferSize: csize_t): natsStatus {.importc: "natsConnection_GetConnectedServerId",
                                    dynlib: dynlibNats.}
proc natsConnection_GetServers*(nc: ptr natsConnection; servers: ptr cstringArray;
                               count: ptr cint): natsStatus {.
    importc: "natsConnection_GetServers", dynlib: dynlibNats.}
proc natsConnection_GetDiscoveredServers*(nc: ptr natsConnection;
    servers: ptr cstringArray; count: ptr cint): natsStatus {.
    importc: "natsConnection_GetDiscoveredServers", dynlib: dynlibNats.}
proc natsConnection_GetLastError*(nc: ptr natsConnection; lastError: cstringArray): natsStatus {.
    importc: "natsConnection_GetLastError", dynlib: dynlibNats.}
proc natsConnection_GetClientID*(nc: ptr natsConnection; cid: ptr uint64): natsStatus {.
    importc: "natsConnection_GetClientID", dynlib: dynlibNats.}
proc natsConnection_Drain*(nc: ptr natsConnection): natsStatus {.
    importc: "natsConnection_Drain", dynlib: dynlibNats.}
proc natsConnection_DrainTimeout*(nc: ptr natsConnection; timeout: int64): natsStatus {.
    importc: "natsConnection_DrainTimeout", dynlib: dynlibNats.}
proc natsConnection_Sign*(nc: ptr natsConnection; message: ptr cuchar;
                         messageLen: cint; sig: array[64, cuchar]): natsStatus {.
    importc: "natsConnection_Sign", dynlib: dynlibNats.}
proc natsConnection_GetClientIP*(nc: ptr natsConnection; ip: cstringArray): natsStatus {.
    importc: "natsConnection_GetClientIP", dynlib: dynlibNats.}
proc natsConnection_GetRTT*(nc: ptr natsConnection; rtt: ptr int64): natsStatus {.
    importc: "natsConnection_GetRTT", dynlib: dynlibNats.}
proc natsConnection_HasHeaderSupport*(nc: ptr natsConnection): natsStatus {.
    importc: "natsConnection_HasHeaderSupport", dynlib: dynlibNats.}
proc natsConnection_GetLocalIPAndPort*(nc: ptr natsConnection; ip: cstringArray;
                                      port: ptr cint): natsStatus {.
    importc: "natsConnection_GetLocalIPAndPort", dynlib: dynlibNats.}
proc natsConnection_Close*(nc: ptr natsConnection) {.
    importc: "natsConnection_Close", dynlib: dynlibNats.}
proc natsConnection_Destroy*(nc: ptr natsConnection) {.
    importc: "natsConnection_Destroy", dynlib: dynlibNats.}
proc natsConnection_Publish*(nc: ptr natsConnection; subj: cstring; data: pointer;
                            dataLen: cint): natsStatus {.
    importc: "natsConnection_Publish", dynlib: dynlibNats.}
proc natsConnection_PublishString*(nc: ptr natsConnection; subj: cstring; str: cstring): natsStatus {.
    importc: "natsConnection_PublishString", dynlib: dynlibNats.}
proc natsConnection_PublishMsg*(nc: ptr natsConnection; msg: ptr natsMsg): natsStatus {.
    importc: "natsConnection_PublishMsg", dynlib: dynlibNats.}
proc natsConnection_PublishRequest*(nc: ptr natsConnection; subj: cstring;
                                   reply: cstring; data: pointer; dataLen: cint): natsStatus {.
    importc: "natsConnection_PublishRequest", dynlib: dynlibNats.}
proc natsConnection_PublishRequestString*(nc: ptr natsConnection; subj: cstring;
    reply: cstring; str: cstring): natsStatus {.
    importc: "natsConnection_PublishRequestString", dynlib: dynlibNats.}
proc natsConnection_Request*(replyMsg: ptr ptr natsMsg; nc: ptr natsConnection;
                            subj: cstring; data: pointer; dataLen: cint;
                            timeout: int64): natsStatus {.
    importc: "natsConnection_Request", dynlib: dynlibNats.}
proc natsConnection_RequestString*(replyMsg: ptr ptr natsMsg; nc: ptr natsConnection;
                                  subj: cstring; str: cstring; timeout: int64): natsStatus {.
    importc: "natsConnection_RequestString", dynlib: dynlibNats.}
proc natsConnection_RequestMsg*(replyMsg: ptr ptr natsMsg; nc: ptr natsConnection;
                               requestMsg: ptr natsMsg; timeout: int64): natsStatus {.
    importc: "natsConnection_RequestMsg", dynlib: dynlibNats.}
proc natsConnection_Subscribe*(sub: ptr ptr natsSubscription; nc: ptr natsConnection;
                              subject: cstring; cb: natsMsgHandler;
                              cbClosure: pointer): natsStatus {.
    importc: "natsConnection_Subscribe", dynlib: dynlibNats.}
proc natsConnection_SubscribeTimeout*(sub: ptr ptr natsSubscription;
                                     nc: ptr natsConnection; subject: cstring;
                                     timeout: int64; cb: natsMsgHandler;
                                     cbClosure: pointer): natsStatus {.
    importc: "natsConnection_SubscribeTimeout", dynlib: dynlibNats.}
proc natsConnection_SubscribeSync*(sub: ptr ptr natsSubscription;
                                  nc: ptr natsConnection; subject: cstring): natsStatus {.
    importc: "natsConnection_SubscribeSync", dynlib: dynlibNats.}
proc natsConnection_QueueSubscribe*(sub: ptr ptr natsSubscription;
                                   nc: ptr natsConnection; subject: cstring;
                                   queueGroup: cstring; cb: natsMsgHandler;
                                   cbClosure: pointer): natsStatus {.
    importc: "natsConnection_QueueSubscribe", dynlib: dynlibNats.}
proc natsConnection_QueueSubscribeTimeout*(sub: ptr ptr natsSubscription;
    nc: ptr natsConnection; subject: cstring; queueGroup: cstring; timeout: int64;
    cb: natsMsgHandler; cbClosure: pointer): natsStatus {.
    importc: "natsConnection_QueueSubscribeTimeout", dynlib: dynlibNats.}
proc natsConnection_QueueSubscribeSync*(sub: ptr ptr natsSubscription;
                                       nc: ptr natsConnection; subject: cstring;
                                       queueGroup: cstring): natsStatus {.
    importc: "natsConnection_QueueSubscribeSync", dynlib: dynlibNats.}
proc natsSubscription_NoDeliveryDelay*(sub: ptr natsSubscription): natsStatus {.
    importc: "natsSubscription_NoDeliveryDelay", dynlib: dynlibNats.}
proc natsSubscription_NextMsg*(nextMsg: ptr ptr natsMsg; sub: ptr natsSubscription;
                              timeout: int64): natsStatus {.
    importc: "natsSubscription_NextMsg", dynlib: dynlibNats.}
proc natsSubscription_Unsubscribe*(sub: ptr natsSubscription): natsStatus {.
    importc: "natsSubscription_Unsubscribe", dynlib: dynlibNats.}
proc natsSubscription_AutoUnsubscribe*(sub: ptr natsSubscription; max: cint): natsStatus {.
    importc: "natsSubscription_AutoUnsubscribe", dynlib: dynlibNats.}
proc natsSubscription_QueuedMsgs*(sub: ptr natsSubscription; queuedMsgs: ptr uint64): natsStatus {.
    importc: "natsSubscription_QueuedMsgs", dynlib: dynlibNats.}
proc natsSubscription_GetID*(sub: ptr natsSubscription): int64 {.
    importc: "natsSubscription_GetID", dynlib: dynlibNats.}
proc natsSubscription_GetSubject*(sub: ptr natsSubscription): cstring {.
    importc: "natsSubscription_GetSubject", dynlib: dynlibNats.}
proc natsSubscription_SetPendingLimits*(sub: ptr natsSubscription; msgLimit: cint;
                                       bytesLimit: cint): natsStatus {.
    importc: "natsSubscription_SetPendingLimits", dynlib: dynlibNats.}
proc natsSubscription_GetPendingLimits*(sub: ptr natsSubscription;
                                       msgLimit: ptr cint; bytesLimit: ptr cint): natsStatus {.
    importc: "natsSubscription_GetPendingLimits", dynlib: dynlibNats.}
proc natsSubscription_GetPending*(sub: ptr natsSubscription; msgs: ptr cint;
                                 bytes: ptr cint): natsStatus {.
    importc: "natsSubscription_GetPending", dynlib: dynlibNats.}
proc natsSubscription_GetDelivered*(sub: ptr natsSubscription; msgs: ptr int64): natsStatus {.
    importc: "natsSubscription_GetDelivered", dynlib: dynlibNats.}
proc natsSubscription_GetDropped*(sub: ptr natsSubscription; msgs: ptr int64): natsStatus {.
    importc: "natsSubscription_GetDropped", dynlib: dynlibNats.}
proc natsSubscription_GetMaxPending*(sub: ptr natsSubscription; msgs: ptr cint;
                                    bytes: ptr cint): natsStatus {.
    importc: "natsSubscription_GetMaxPending", dynlib: dynlibNats.}
proc natsSubscription_ClearMaxPending*(sub: ptr natsSubscription): natsStatus {.
    importc: "natsSubscription_ClearMaxPending", dynlib: dynlibNats.}
proc natsSubscription_GetStats*(sub: ptr natsSubscription; pendingMsgs: ptr cint;
                               pendingBytes: ptr cint; maxPendingMsgs: ptr cint;
                               maxPendingBytes: ptr cint; deliveredMsgs: ptr int64;
                               droppedMsgs: ptr int64): natsStatus {.
    importc: "natsSubscription_GetStats", dynlib: dynlibNats.}
proc natsSubscription_IsValid*(sub: ptr natsSubscription): bool {.
    importc: "natsSubscription_IsValid", dynlib: dynlibNats.}
proc natsSubscription_Drain*(sub: ptr natsSubscription): natsStatus {.
    importc: "natsSubscription_Drain", dynlib: dynlibNats.}
proc natsSubscription_DrainTimeout*(sub: ptr natsSubscription; timeout: int64): natsStatus {.
    importc: "natsSubscription_DrainTimeout", dynlib: dynlibNats.}
proc natsSubscription_WaitForDrainCompletion*(sub: ptr natsSubscription;
    timeout: int64): natsStatus {.importc: "natsSubscription_WaitForDrainCompletion",
                               dynlib: dynlibNats.}
proc natsSubscription_DrainCompletionStatus*(sub: ptr natsSubscription): natsStatus {.
    importc: "natsSubscription_DrainCompletionStatus", dynlib: dynlibNats.}
proc natsSubscription_SetOnCompleteCB*(sub: ptr natsSubscription;
                                      cb: natsOnCompleteCB; closure: pointer): natsStatus {.
    importc: "natsSubscription_SetOnCompleteCB", dynlib: dynlibNats.}
proc natsSubscription_Destroy*(sub: ptr natsSubscription) {.
    importc: "natsSubscription_Destroy", dynlib: dynlibNats.}