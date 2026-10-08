---
id: release-note
content_type: tech-docs
summary: Tells users what changed in a release and what they need to do.
sections:
  - name: Version and date
    required: true
    length: "one line"
  - name: Breaking changes
    required: false
    length: "first, if any: what changed and the exact action to take"
  - name: New
    required: false
    length: "one bullet per change, starting with what the user can now do"
  - name: Fixed
    required: false
    length: "one bullet per fix, describing the symptom that's gone"
  - name: Deprecated
    required: false
    length: "what, when it's removed, what to use instead"
---
## 2.4.0 (2026-10-07)

### Breaking changes
- API keys created before 2.0 stop working on 1 December. Create new keys in **Settings** > **API keys** before then.

### New
- You can set an expiry date when you create an API key.

### Fixed
- Revoked keys no longer appear in the key list after a page refresh.
