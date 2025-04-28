# fakePA
heath appointment maker

# How to run app

## dependencies

- Zig version 0.14.0 or above
- Postgres
> Username : postgres
> Database : fakepapq
> port    : 5432
- ollama (preferably with gemma3, and mxbai-embed-large already installed)

```bash
cd fakepa-server
zig build run
```

# Other files

- offline(python based) version in fake_nlp.py (this is text based and does not use semantic embeddings. this causes it's performance to be hit hard)

