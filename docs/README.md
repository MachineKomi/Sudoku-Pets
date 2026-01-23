# Documentation

This folder contains all project documentation consolidated from the original scattered locations.

## Structure

```
docs/
├── design/                  # Technical design documents
│   ├── sudoku_pets_components.md  # Full component model
│   └── domain_models/       # DDD domain models by bounded context
│       ├── core_sudoku_domain.md
│       ├── meta_progression_domain.md
│       ├── pet_system_domain.md
│       └── polish_wrapper_domain.md
│
├── requirements/            # What to build
│   ├── user_stories.md     # User stories with acceptance criteria
│   ├── gdd.md              # Game Design Document
│   ├── ui-spec.md          # UI/UX specification
│   └── technical_spec.md   # Technical specification
│
├── plans/                   # Implementation plans
│   ├── stories_plan.md     # User stories creation plan
│   ├── units_plan.md       # Units breakdown plan
│   ├── component_model.md  # Component model planning
│   ├── domain_design_plan.md
│   └── tasks_plan.md
│
├── status/                  # Project tracking
│   ├── aidlc-state.md      # Current development state
│   ├── audit.md            # Decision log
│   └── HANDOFF_SUMMARY.md  # Context for new developers
│
└── archive/                 # Legacy/obsolete documents
    ├── GEMINI_PROMPT.md
    └── WhitepaperPrompts.md
```

## Quick Links

- **Start here**: [HANDOFF_SUMMARY.md](status/HANDOFF_SUMMARY.md)
- **What to build**: [user_stories.md](requirements/user_stories.md)
- **Full game design**: [gdd.md](requirements/gdd.md)
- **Component architecture**: [sudoku_pets_components.md](design/sudoku_pets_components.md)
