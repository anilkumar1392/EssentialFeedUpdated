### FeedStore implementation Inbox

### - Retrieve
    - Empty cache works (before something is inserted)
    - Retrieve empty cache twice returns empty (no side-effects)
    - Non-empty cache returns data
    - Non-empty cache twice returns same data (retrieve should have no side-effects)
    - Error returns error (if applicable to simulate, e.g., invalid data)
    - Error twice returns same error  (if applicable to simulate, e.g., invalid data)
    
### Insert
    - To empty cache works
    - To non-empty cache overrides previous value
    - Error (if possible to simulate, e.g., no write permission)
    
### - Delete
    - Empty cache does nothing (cache stays empty and does not fail)
    - Inserted data leaves cache empty
    - Error (if possible to simulate, e.g., no write permission)

### - Side-effects must run serially to avoid race-conditions (deleting the wrong cache... overriding the latest data...)
