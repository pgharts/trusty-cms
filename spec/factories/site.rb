FactoryBot.define do
  factory :site do
    sequence(:name) { |n| "Site #{n}" }
    sequence(:base_domain) { |n| "site#{n}.example.com" }
    # domain is stored as a regexp string and validated for uniqueness.
    sequence(:domain) { |n| "site#{n}\\.example\\.com" }
  end
end
