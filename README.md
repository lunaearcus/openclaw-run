# OpenClaw on Gloud Run

## Tips

- .openclaw 自体を /mnt/.openclaw に都度都度バックアップを指示するといいよ
- Pixel Terminal で gcloud run services proxy すると、 Google Pixel から使えるよ

## File Samples

### credentails/openclaw.json

```
{
  "gateway": {
    "mode": "local",
    "port": 18789,
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "<TOKEN>"
    },
    "controlUi": {
      "enabled": true,
      "allowInsecureAuth": true,
      "allowedOrigins": [
        "http://localhost:8080"
      ]
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "google-vertex/gemini-2.5-flash"
      }
    }
  }
}
```

### credentails/agents/main/agent/auth-profiles.json

```
{
  "version": 1,
  "profiles": {
    "google-vertex:default": {
      "type": "api_key",
      "provider": "google-vertex",
      "key": "<anything-non-empty>"
    }
  }
}
```
