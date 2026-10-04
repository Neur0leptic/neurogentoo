// Union of nchat 5.18.20's lib/{wmchat,sgchat}/go/go.mod requirements.
// Shared dependencies use the higher upstream-pinned version (Go MVS).
module github.com/d99kris/nchat/lib/gostat

go 1.25.0

replace go.mau.fi/whatsmeow => @WM_DIR@/ext/whatsmeow
replace go.mau.fi/mautrix-signal => @SG_DIR@/ext/signal

require (
	filippo.io/edwards25519 v1.2.0
	github.com/beeper/argo-go v1.1.2
	github.com/coder/websocket v1.8.15
	github.com/elliotchance/orderedmap/v3 v3.1.0
	github.com/google/uuid v1.6.0
	github.com/mattn/go-colorable v0.1.14
	github.com/mattn/go-isatty v0.0.20
	github.com/mattn/go-pointer v0.0.1
	github.com/mattn/go-sqlite3 v1.14.48
	github.com/mdp/qrterminal v1.0.1
	github.com/petermattis/goid v0.0.0-20260713124913-97594f28f5ca
	github.com/rs/zerolog v1.35.1
	github.com/skip2/go-qrcode v0.0.0-20200617195104-da1b6568686e
	github.com/tidwall/gjson v1.19.0
	github.com/tidwall/match v1.2.0
	github.com/tidwall/pretty v1.2.1
	github.com/vektah/gqlparser/v2 v2.5.27
	go.mau.fi/libsignal v0.2.2
	go.mau.fi/mautrix-signal v0.0.0
	go.mau.fi/util v0.9.12-0.20260719092501-f9c03d846391
	go.mau.fi/whatsmeow v0.0.0
	golang.org/x/crypto v0.54.0
	golang.org/x/exp v0.0.0-20260709172345-9ea1abe57597
	golang.org/x/net v0.57.0
	golang.org/x/sync v0.22.0
	golang.org/x/sys v0.47.0
	golang.org/x/text v0.40.0
	google.golang.org/protobuf v1.36.11
	rsc.io/qr v0.2.0
)
