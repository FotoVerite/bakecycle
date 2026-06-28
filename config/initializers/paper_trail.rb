# frozen_string_literal: true

# track_associations removed in PaperTrail 10+; false is now the default

# `versions.object_changes` is YAML-serialized and includes BigDecimal/Date/Time
# attributes (prices, weights, dates). Rails' safe YAML loader only permits Symbol
# by default, so without this, `version.changeset` silently raises and is rescued
# to `{}` -- the papertrail views render a heading with no change history at all.
ActiveRecord.yaml_column_permitted_classes += [
  BigDecimal, Date, Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone
]
