# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription do
    shredder_id ""
    area_id ""
    inches "4"
    type ""
    message 'FRESHIEZ! Bachy is reporting {{new_snow}}" in the last 12 hours. Base Temp: {{base_temp}}. Reported At: {{report_time}}'
  end
end
