import Principal "mo:base/Principal";

actor {
    public shared query (msg) func greet(name : Text) : async Text {
        return "Hello, " # name # "! " # Principal.toText(msg.caller);
    };
};
