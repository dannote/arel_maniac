# frozen_string_literal: true

# No custom visitor patches needed — Rails 8 PostgreSQL visitor supports
# DISTINCT ON, LATERAL, TABLESAMPLE natively via Arel.
# This file exists as an extension point for future visitor customizations.
