# GitHub Copilot Tools Guide

> **A comprehensive guide to using the AI-powered tools in this workspace**

Last Updated: February 17, 2026

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Tool Categories](#tool-categories)
4. [How to Use Agents](#how-to-use-agents)
5. [How to Use Prompts](#how-to-use-prompts)
6. [How to Use Instructions](#how-to-use-instructions)
7. [Practical Examples](#practical-examples)
8. [Tips & Best Practices](#tips--best-practices)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This workspace includes **9 AI-powered tools** from the [Awesome Copilot](https://github.com/timheuer/awesome-copilot) community repository to enhance your database learning experience:

### 🤖 Agents (2)
Specialized AI assistants for database administration tasks
- `@postgresql-dba` - PostgreSQL Database Administrator
- `@ms-sql-dba` - Microsoft SQL Server Database Administrator

### 📝 Prompts (5)
Task-specific assistants for code optimization and learning
- `/remember` - Track lessons learned
- `sql-optimization` - Universal SQL performance optimization
- `sql-code-review` - Universal SQL code review
- `postgresql-optimization` - PostgreSQL-specific optimization
- `postgresql-code-review` - PostgreSQL-specific code review

### 📋 Instructions (2)
Automatic coding guidelines applied to SQL files
- `ms-sql-dba.instructions.md` - MS-SQL best practices
- `sql-sp-generation.instructions.md` - SQL schema & stored procedure standards

---

## ✅ Prerequisites

### Required Extensions

1. **GitHub Copilot** (base extension)
   - Already included in VS Code with your subscription

2. **Awesome Copilot** (community tools browser)
   - Extension ID: `timheuer.awesome-copilot`
   - Version: 0.1.40 or later
   - Status: ✅ Already installed in this workspace

3. **Database Extensions** (for agents)
   - For PostgreSQL: `ms-ossdata.vscode-pgsql`
   - For SQL Server: `ms-mssql.mssql`
   - Install only the ones you need for your database work

### Required Software

- **Docker Desktop** - Required for Awesome Copilot's MCP server
  - Status: ✅ Already running
  - Ensure it's always running when using agents

---

## 🛠️ Tool Categories

### What Are Agents?

**Agents** are specialized AI chat modes with specific expertise and tools. Think of them as expert colleagues you can consult.

- **Location**: `.github/agents/*.agent.md`
- **How to Use**: Type `@agent-name` in GitHub Copilot Chat
- **Capabilities**: Database inspection, query optimization, administration tasks

### What Are Prompts?

**Prompts** are pre-written instructions that help Copilot perform specific tasks more effectively.

- **Location**: `.github/prompts/*.prompt.md`
- **How to Use**: Type `/prompt-name` in GitHub Copilot Chat (or select code and use)
- **Capabilities**: Code review, optimization suggestions, lesson tracking

### What Are Instructions?

**Instructions** are automatic guidelines that Copilot follows when generating code in your workspace.

- **Location**: `.github/instructions/*.instructions.md`
- **How to Use**: Automatic (no action needed)
- **Capabilities**: Enforce coding standards, naming conventions, best practices

---

## 🤖 How to Use Agents

### Agent: PostgreSQL Database Administrator

**Name**: `@postgresql-dba`

**When to Use**:
- Setting up PostgreSQL databases
- Optimizing PostgreSQL queries
- Managing backups and performance
- PostgreSQL security configuration

**Example Usage**:

1. Open GitHub Copilot Chat panel (Ctrl+Shift+I or Cmd+Shift+I)
2. Type `@postgresql-dba` followed by your question:

```
@postgresql-dba How do I create a database with proper UTF-8 encoding?
```

```
@postgresql-dba Analyze this query for performance issues:
SELECT * FROM users WHERE email LIKE '%@gmail.com'
```

```
@postgresql-dba What's the best way to backup a PostgreSQL database?
```

**Required Extension**: `ms-ossdata.vscode-pgsql`

---

### Agent: MS-SQL Database Administrator

**Name**: `@ms-sql-dba`

**When to Use**:
- Setting up SQL Server databases
- Optimizing T-SQL queries
- SQL Server backups and recovery
- SQL Server 2025+ features

**Example Usage**:

```
@ms-sql-dba How do I create a new database with specific collation?
```

```
@ms-sql-dba Review this stored procedure for security issues:
CREATE PROCEDURE GetUser @Email VARCHAR(255)
AS
BEGIN
    SELECT * FROM Users WHERE Email = @Email
END
```

```
@ms-sql-dba What are the best practices for indexing in SQL Server?
```

**Required Extension**: `ms-mssql.mssql`

---

## 📝 How to Use Prompts

### Prompt: Remember (/remember)

**Purpose**: Track lessons learned during your studies and organize them into domain-specific memory files.

**Syntax**:
```
/remember [>domain [scope]] your lesson content here
```

**Scopes**:
- `global` - Saved to all VS Code projects (vscode-userdata:/User/prompts/)
- `workspace` - Saved only to this project (.github/instructions/)

**Examples**:

Track a database lesson globally:
```
/remember >database global Always use TIMESTAMPTZ instead of TIMESTAMP in PostgreSQL for timezone-aware dates
```

Track a SQL lesson for this workspace only:
```
/remember >sql workspace Never use SELECT * in production queries - always specify column names
```

Auto-categorize a lesson (Copilot picks the domain):
```
/remember Composite indexes should put the most selective column first for better performance
```

**When to Use**:
- After learning something important in class
- When you discover a mistake and want to remember the fix
- To build your personal knowledge base
- Before exams to consolidate learnings

---

### Prompt: SQL Optimization

**Purpose**: Get expert help optimizing SQL queries for performance.

**Supports**: MySQL, PostgreSQL, SQL Server, Oracle

**When to Use**:
- Slow queries that need optimization
- Learning query optimization techniques
- Before code reviews
- Preparing production queries

**How to Use**:

1. Select a SQL query in your editor
2. Open Copilot Chat
3. Type: "Optimize this SQL query" or use the prompt directly

**Example**:
```sql
-- Select this code and ask Copilot to optimize it
SELECT * FROM orders 
WHERE user_id IN (SELECT id FROM users WHERE created_at > '2024-01-01')
ORDER BY created_at DESC;
```

Then ask:
```
Can you optimize this query for performance? Check for index opportunities and inefficient patterns.
```

**What You'll Get**:
- Performance analysis
- Recommended indexes
- Rewritten optimized query
- Explanation of improvements

---

### Prompt: SQL Code Review

**Purpose**: Comprehensive review of SQL code for security, performance, and quality.

**Supports**: All SQL dialects

**When to Use**:
- Before submitting homework/assignments
- Before deploying to production
- Learning SQL best practices
- Preparing for code reviews

**How to Use**:

Select your SQL code and ask for a review:
```
Review this SQL code for security issues, performance problems, and best practices.
```

**What You'll Get**:
- Security analysis (SQL injection, access control)
- Performance issues identified
- Code quality suggestions
- Scoring (1-10) for security/performance/maintainability

---

### Prompt: PostgreSQL Optimization

**Purpose**: PostgreSQL-specific optimization using advanced features (JSONB, arrays, extensions).

**When to Use**:
- Working with PostgreSQL-exclusive features
- Optimizing JSONB queries
- Using PostgreSQL extensions
- Window functions and CTEs

**How to Use**:

```
I'm working with PostgreSQL JSONB. How can I optimize this query?
SELECT * FROM events WHERE data->>'type' = 'login'
```

**What You'll Get**:
- PostgreSQL-specific index recommendations (GIN, GiST)
- JSONB query optimization
- Extension suggestions
- Advanced PostgreSQL features you can use

---

### Prompt: PostgreSQL Code Review

**Purpose**: PostgreSQL-specific code review focusing on unique PostgreSQL capabilities.

**When to Use**:
- Reviewing PostgreSQL schemas
- Ensuring PostgreSQL best practices
- Validating JSONB/array usage
- Custom types and domains review

**How to Use**:

```
Review this PostgreSQL schema design:
CREATE TABLE users (
    id INTEGER,
    email VARCHAR(255),
    metadata JSON
);
```

**What You'll Get**:
- PostgreSQL-specific improvements (CITEXT, JSONB, ENUM types)
- Index strategy for PostgreSQL
- Extension recommendations
- PostgreSQL anti-patterns to avoid

---

## 📋 How to Use Instructions

Instructions work **automatically** in the background. They guide Copilot when you're writing code.

### Instruction: MS-SQL DBA

**Applied to**: All files (`**`)

**What It Does**:
- Recommends SQL Server best practices
- Warns about deprecated SQL Server features
- Links to official Microsoft documentation
- Ensures secure, performance-oriented code

**Example**:
When you ask Copilot to "create a SQL Server table", it will automatically:
- Use proper naming conventions
- Include appropriate constraints
- Follow SQL Server 2025+ standards
- Avoid deprecated features

---

### Instruction: SQL Stored Procedure Generation

**Applied to**: All SQL files (`**/*.sql`)

**What It Does**:
- Enforces naming conventions (tables singular, `usp_` for procedures)
- Implements parameterized queries
- Adds proper error handling
- Includes transaction management

**Example**:
When you ask Copilot to "create a stored procedure to update user email", it will automatically:
```sql
CREATE PROCEDURE usp_UpdateUserEmail
    @UserId INT,
    @NewEmail NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Users
        SET Email = @NewEmail,
            UpdatedAt = GETUTCDATE()
        WHERE Id = @UserId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
```

---

## 💡 Practical Examples

### Example 1: Learning Session with /remember

**Scenario**: You're studying PostgreSQL indexing and discover something important.

```
/remember >postgresql workspace GIN indexes are best for JSONB and array columns because they support containment operators like @> and ?
```

**Result**: This lesson is saved to `.github/instructions/postgresql.instructions.md` for this workspace. Copilot will remember it when generating PostgreSQL code!

---

### Example 2: Query Optimization

**Scenario**: Your homework SQL query is slow.

1. Select this code:
```sql
SELECT * FROM students 
WHERE grade IN (SELECT grade FROM honor_roll WHERE year = 2024)
```

2. Ask Copilot:
```
Optimize this query - it's running too slow on large datasets
```

3. Get recommendations:
- Remove `SELECT *`
- Use JOIN instead of subquery
- Add index on `grade` column
- Optimized version provided

---

### Example 3: Using Database Agent

**Scenario**: You need to create a PostgreSQL database for your project.

```
@postgresql-dba I need to create a database for a library system with proper encoding and timezone support. What's the best practice?
```

**What happens**:
- Agent provides step-by-step commands
- Explains UTF-8 encoding setup
- Suggests timezone configuration
- May offer to execute commands if extension is connected

---

### Example 4: Code Review Before Submission

**Scenario**: Assignment due tomorrow, want to ensure code quality.

1. Select your entire SQL file
2. Ask:
```
Please review this SQL code for my database assignment. Check for security issues, performance problems, and best practices.
```

3. Get comprehensive feedback:
- Security vulnerabilities found
- Performance improvements suggested
- Best practices violations noted
- Score provided (e.g., 7/10)

---

## 🎓 Tips & Best Practices

### For Students

1. **Use /remember throughout your studies**
   - After each class: `/remember` key concepts
   - After fixing bugs: `/remember` the solution
   - Before exams: Review your `.github/instructions/` folder

2. **Ask agents for explanations, not just answers**
   - Good: `@postgresql-dba Why should I use TIMESTAMPTZ?`
   - Better: `@postgresql-dba Explain the difference between TIMESTAMP and TIMESTAMPTZ with examples`

3. **Review code before submitting assignments**
   - Select all SQL → Ask for code review
   - Fix issues identified
   - Review again to confirm improvements

4. **Combine tools for maximum learning**
   ```
   1. Write SQL query
   2. Ask for optimization review
   3. Use /remember to save the lesson learned
   4. Apply to next assignment
   ```

### Best Practices

- **Be Specific**: "Optimize this PostgreSQL JSONB query" is better than "make this faster"
- **Provide Context**: Tell agents what database version you're using
- **Iterate**: Use feedback to improve, then ask for review again
- **Learn, Don't Copy**: Understand why Copilot suggests changes
- **Experiment**: Try different phrasings to get better results

### Common Workflows

**Study Workflow**:
```
1. Learn concept in class
2. /remember >database workspace [concept]
3. Practice with SQL exercises
4. Ask agents for explanations
5. Review before exam
```

**Assignment Workflow**:
```
1. Write SQL solution
2. Select code → Ask for optimization
3. Apply suggestions
4. Ask for code review
5. Fix issues
6. /remember any important lessons
7. Submit assignment
```

**Project Workflow**:
```
1. Design schema
2. @postgresql-dba review my schema design
3. Write queries
4. Optimize with prompts
5. Review before deployment
6. /remember production lessons
```

---

## 🔧 Troubleshooting

### Agents Not Appearing

**Problem**: Typing `@postgresql-dba` doesn't show the agent

**Solutions**:
1. Ensure Awesome Copilot extension is installed and enabled
2. Restart VS Code
3. Check Docker Desktop is running
4. Verify files exist in `.github/agents/` folder

---

### Prompts Not Working

**Problem**: `/remember` doesn't trigger the prompt

**Solutions**:
1. Make sure you're using GitHub Copilot Chat (not inline suggestions)
2. Type the command at the start of your message
3. Check `.github/prompts/` folder for prompt files
4. Reload VS Code window

---

### Instructions Not Applied

**Problem**: Copilot generates code that doesn't follow workspace standards

**Solutions**:
1. Check `.github/instructions/` folder exists with instruction files
2. Ensure file patterns match (e.g., `**/*.sql` for SQL files)
3. Be explicit: "Generate SQL following workspace instructions"
4. Reload VS Code window

---

### Database Agent Can't Connect

**Problem**: Agent says it can't connect to database

**Solutions**:
1. Install required extension:
   - PostgreSQL: `ms-ossdata.vscode-pgsql`
   - SQL Server: `ms-mssql.mssql`
2. Configure database connection in extension
3. Ensure database server is running
4. Check connection credentials

---

### Docker Issues

**Problem**: Awesome Copilot shows Docker errors

**Solutions**:
1. Ensure Docker Desktop is installed and running
2. Restart Docker Desktop
3. Restart VS Code after Docker is running
4. Check Docker Desktop settings (should be running in background)

---

## 📚 Additional Resources

### Documentation
- [Awesome Copilot Repository](https://github.com/timheuer/awesome-copilot)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)

### Workspace Resources
- Main README: [`README.md`](README.md)
- Implementation Progress: [`IMPLEMENTATION-PROGRESS.md`](IMPLEMENTATION-PROGRESS.md)
- Notes: [`notes/README.md`](notes/README.md)
- SQL Practice: [`sql-practice/README.md`](sql-practice/README.md)

### Tool Files Location
```
.github/
├── agents/
│   ├── postgresql-dba.agent.md
│   └── ms-sql-dba.agent.md
├── prompts/
│   ├── remember.prompt.md
│   ├── sql-optimization.prompt.md
│   ├── sql-code-review.prompt.md
│   ├── postgresql-optimization.prompt.md
│   └── postgresql-code-review.prompt.md
└── instructions/
    ├── ms-sql-dba.instructions.md
    └── sql-sp-generation.instructions.md
```

---

## 🎯 Quick Reference Card

| Tool | Usage | Purpose |
|------|-------|---------|
| `@postgresql-dba` | Chat agent | PostgreSQL database administration |
| `@ms-sql-dba` | Chat agent | SQL Server database administration |
| `/remember` | Chat command | Track lessons learned |
| SQL Optimization | Select code + ask | Optimize SQL queries |
| SQL Code Review | Select code + ask | Review code quality |
| PostgreSQL Optimization | Select code + ask | PostgreSQL-specific optimization |
| PostgreSQL Code Review | Select code + ask | PostgreSQL-specific review |
| Instructions | Automatic | Enforce coding standards |

---

## 📝 Quick Start Checklist

- [ ] Verify GitHub Copilot is active
- [ ] Confirm Awesome Copilot extension is installed
- [ ] Ensure Docker Desktop is running
- [ ] Install database extensions (PostgreSQL/SQL Server) if needed
- [ ] Try `@postgresql-dba` or `@ms-sql-dba` in chat
- [ ] Test `/remember` command with a sample lesson
- [ ] Select SQL code and ask for optimization
- [ ] Review this guide's examples for your first tasks

---

**Happy Learning!** 🚀

*These AI tools are here to enhance your database modeling studies. Use them to learn faster, write better code, and build your expertise.*

---

**Created**: February 17, 2026  
**Author**: Miyen Brandolino  
**Workspace**: Database Modeling Study - Licenciatura en Informática / Análisis y Gestión de Datos  
**Tools Source**: [Awesome Copilot Community](https://github.com/timheuer/awesome-copilot)
