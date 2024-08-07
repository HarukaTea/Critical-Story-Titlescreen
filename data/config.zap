
opt client_output = "../src/modules/Data/Events.luau"
opt server_output = "../src/server/Modules/Data/ServerEvents.luau"

event CreateHint = {
    from: Server,
    type: Unreliable,
    call: ManyAsync,
    data: struct {
        Hint: string(..666)
    }
}
event CreateFullScreenHint = {
    from: Server,
    type: Unreliable,
    call: ManyAsync,
    data: struct {
        Hint: string(..666),
        State: boolean
    }
}
event DataWipe = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        SlotChosen: string
    }
}
event DataTransfer = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {}
}
event TeleportFailed = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: struct {}
}
event TeleportPrompt = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        Option: string,
        PrivateCode: unknown,
        SlotChosen: string
    }
}