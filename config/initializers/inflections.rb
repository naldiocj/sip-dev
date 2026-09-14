# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific. You can also define inflections for about as many
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1en"
# end

# These inflection rules are supported but not enabled by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.uncountable %w[ process ]
end
