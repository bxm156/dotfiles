# Data Engineering Agent Team - User Guide

## 🚀 Quick Start

These specialized data engineering agents are now available in your Claude Code environment. They work as a parallel-processing expert team, each with deep specialization in critical data engineering domains.

## 📋 Agent Roster

### Core Team (Most Frequently Used)
1. **dbt-engineering-specialist** - DBT development and testing expert
2. **sql-optimization-specialist** - Query performance and optimization
3. **data-quality-guardian** - Data validation and quality assurance
4. **pipeline-orchestration-director** - Workflow automation and orchestration

### Specialized Team
5. **kimball-dimensional-architect** - Star schema and dimensional modeling
6. **data-catalog-librarian** - Documentation and metadata management
7. **infrastructure-performance-engineer** - Storage and compute optimization
8. **schema-evolution-architect** - Migration and version control
9. **data-observability-monitor** - Monitoring and alerting
10. **data-reconciliation-validator** - Cross-system validation

## 🎯 How to Use These Agents

### Automatic Invocation
Claude Code will automatically select the appropriate agent based on your request:
- Mention "star schema" → Kimball Dimensional Architect
- Ask about "slow query" → SQL Optimization Specialist
- Request "data quality checks" → Data Quality Guardian
- Say "DBT model" → DBT Engineering Specialist

### Explicit Invocation
You can also explicitly request specific agents:
```
"Use the SQL Optimization Specialist to improve this query"
"Have the DBT Engineer create incremental models for these tables"
"Get the Data Quality Guardian to validate this migration"
```

### Parallel Execution
For complex tasks, multiple agents can work simultaneously:
```
"Review this data pipeline and optimize it"
→ Pipeline Orchestrator + SQL Optimizer + Quality Guardian work in parallel
```

## 📚 Common Use Cases

### 1. Building a New Data Warehouse
```
"Design a star schema for our sales data"
```
**Active Agents:**
- Kimball Dimensional Architect (designs schema)
- DBT Engineering Specialist (builds models)
- Data Quality Guardian (creates tests)
- Data Catalog Librarian (documents)

### 2. Optimizing Slow Queries
```
"This dashboard query is taking 5 minutes to run"
```
**Active Agents:**
- SQL Optimization Specialist (rewrites query)
- Infrastructure Performance Engineer (checks indexes/partitions)

### 3. Setting Up Data Quality Framework
```
"Implement comprehensive data quality checks for our pipeline"
```
**Active Agents:**
- Data Quality Guardian (designs checks)
- DBT Engineering Specialist (implements tests)
- Data Observability Monitor (sets up monitoring)

### 4. Data Migration Project
```
"Migrate our warehouse from PostgreSQL to Snowflake"
```
**Active Agents:**
- Schema Evolution Architect (plans migration)
- Data Reconciliation Validator (validates data)
- Pipeline Orchestration Director (orchestrates migration)

### 5. Production Issue Investigation
```
"Our pipeline failed and data looks incorrect"
```
**Active Agents:**
- Data Observability Monitor (checks metrics)
- Data Quality Guardian (runs validation)
- Pipeline Orchestration Director (reviews logs)
- Data Reconciliation Validator (compares systems)

## 🏗️ Best Practices

### 1. **Start with Context**
Provide clear context about your data stack:
- Database platform (Snowflake, BigQuery, PostgreSQL)
- Current tools (DBT, Airflow, etc.)
- Data volume and complexity
- Specific pain points

### 2. **Use Parallel Processing**
When facing complex problems, let multiple agents work together:
```
"Build a complete data pipeline with quality checks and monitoring"
```

### 3. **Iterate with Agents**
Agents can refine their work based on feedback:
```
"The query is faster but still not meeting SLA, optimize further"
```

### 4. **Leverage Specialization**
Use the right agent for the right task:
- Don't ask the SQL Optimizer to design schemas
- Don't ask the Kimball Architect to write Airflow DAGs

## 💡 Pro Tips

### For DBT Projects
1. Start with DBT Engineering Specialist for project structure
2. Add Data Quality Guardian for comprehensive testing
3. Use SQL Optimization Specialist for slow models
4. Finish with Data Catalog Librarian for documentation

### For Performance Issues
1. Begin with SQL Optimization Specialist for query analysis
2. Bring in Infrastructure Performance Engineer for platform-specific tuning
3. Use Data Observability Monitor to track improvements

### For New Implementations
1. Start with Kimball Dimensional Architect for data modeling
2. Use DBT Engineering Specialist for transformation logic
3. Add Pipeline Orchestration Director for workflow automation
4. Include Data Quality Guardian from the start

## 🔧 Agent Capabilities

### Query Optimization
- Execution plan analysis
- Index recommendations
- Query rewrites
- Platform-specific optimizations

### Data Quality
- Completeness checks
- Accuracy validation
- Anomaly detection
- Statistical profiling

### Pipeline Management
- Idempotent design
- Error handling
- Retry strategies
- Dependency management

### Documentation
- Auto-generated data dictionaries
- Lineage tracking
- Business glossaries
- Compliance documentation

## 📊 Success Metrics

Agents help you achieve:
- **50-90% query performance improvement**
- **99%+ data quality scores**
- **Zero-downtime schema migrations**
- **Automated pipeline recovery**
- **Complete data lineage documentation**

## 🆘 Troubleshooting

### Agent Not Responding as Expected?
1. Be more specific about your needs
2. Explicitly name the agent you want
3. Provide example data or queries
4. Specify your platform (Snowflake, BigQuery, etc.)

### Multiple Agents Needed?
Request parallel execution:
```
"I need to optimize this pipeline - check performance, quality, and documentation"
```

### Need Different Expertise?
Combine agents:
```
"Design the schema with Kimball expert, then implement with DBT engineer"
```

## 🎓 Learning Resources

Each agent includes:
- Code examples in their domain
- Best practices checklists
- Common anti-patterns to avoid
- Platform-specific guidance
- Industry-standard methodologies

## 🚦 Getting Started Checklist

- [ ] Identify your primary data engineering challenge
- [ ] Select the appropriate agent(s)
- [ ] Provide context about your environment
- [ ] Review agent recommendations
- [ ] Implement suggestions incrementally
- [ ] Use monitoring agents to track improvements
- [ ] Document changes with catalog librarian

## 📈 Continuous Improvement

These agents learn from:
- Your feedback and corrections
- Patterns in your codebase
- Your organization's best practices
- Industry evolution and new tools

## 🔄 Typical Workflow

1. **Discovery** → Data Observability Monitor analyzes current state
2. **Design** → Kimball Architect designs solution
3. **Implementation** → DBT Engineer + Pipeline Orchestrator build
4. **Validation** → Data Quality Guardian + Reconciliation Validator test
5. **Optimization** → SQL Optimizer + Infrastructure Engineer tune
6. **Documentation** → Data Catalog Librarian documents
7. **Monitoring** → Observability Monitor tracks production

---

**Remember:** These agents are your specialized data engineering team. Use them individually for focused tasks or together for comprehensive solutions. They follow industry best practices while adapting to your specific needs.

**Pro Tip:** Start with one agent for simple tasks, then gradually incorporate multiple agents as you tackle more complex challenges. The agents work best when they can build on each other's work!