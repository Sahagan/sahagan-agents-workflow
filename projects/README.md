# Projects

## Task Log
`task-log.jsonl` — JSON Lines format, one task per line

อั่งเปา update ไฟล์นี้ระหว่าง session เพื่อ track งานของแต่ละ agent

## Schema
```json
{
  "taskId": "PROJ-1",
  "agent": "phayu",
  "status": "in_progress",
  "task": "Implement user auth API",
  "files": ["src/auth/index.ts"],
  "startedAt": "2026-06-13T10:00:00Z",
  "completedAt": null,
  "blockers": [],
  "verificationGate": "pending",
  "qaApproved": false
}
```

## Status Values
- `pending` — รอทำ
- `in_progress` — กำลังทำ
- `blocked` — ติดขัด รอ unblock
- `completed` — เสร็จแล้ว
- `failed` — ล้มเหลว
