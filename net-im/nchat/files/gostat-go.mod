// Generated from the pinned nchat protocol module requirements.
module github.com/d99kris/nchat/lib/gostat

go 1.26.0

require (
	filippo.io/edwards25519 v1.2.0
	github.com/beeper/argo-go v1.1.2
	github.com/coder/websocket v1.8.15
	github.com/elliotchance/orderedmap/v3 v3.1.0
	github.com/google/uuid v1.6.0
	github.com/mattn/go-colorable v0.1.14
	github.com/mattn/go-isatty v0.0.20
	github.com/mattn/go-pointer v0.0.1
	github.com/mattn/go-sqlite3 v1.14.52
	github.com/mdp/qrterminal v1.0.1
	github.com/petermattis/goid v0.0.0-20260918085751-abfca077860b
	github.com/rs/zerolog v1.35.1
	github.com/skip2/go-qrcode v0.0.0-20200617195104-da1b6568686e
	github.com/tidwall/gjson v1.20.0
	github.com/tidwall/match v1.2.0
	github.com/tidwall/pretty v1.2.1
	github.com/vektah/gqlparser/v2 v2.5.27
	go.mau.fi/libsignal v0.2.2
	go.mau.fi/mautrix-signal v0.0.0
	go.mau.fi/util v0.11.0
	go.mau.fi/whatsmeow v0.0.0
	golang.org/x/crypto v0.58.0
	golang.org/x/exp v0.0.0-20261014143641-f0251eb4aa3e
	golang.org/x/net v0.61.0
	golang.org/x/sync v0.24.0
	golang.org/x/sys v0.49.0
	golang.org/x/text v0.43.0
	google.golang.org/genproto/googleapis/rpc v0.0.0-20260706201446-f0a921348800
	google.golang.org/grpc v1.84.0
	google.golang.org/protobuf v1.36.12
	rsc.io/qr v0.2.0
)

replace go.mau.fi/whatsmeow => @WM_DIR@/ext/whatsmeow

replace go.mau.fi/mautrix-signal => @SG_DIR@/ext/signal
