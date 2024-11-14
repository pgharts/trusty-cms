FactoryBot.define do
  factory :user do
    first_name { 'FirstName' }
    last_name { 'LastName' }
    email { 'email@test.com' }
    password { 'ComplexPass1!' }
    password_confirmation { password }

    factory :admin do
      first_name { 'FirstName' }
      last_name { 'LastName' }
      email { 'admin@example.com' }
      admin { true }
    end

    factory :existing do
      first_name { 'FirstName' }
      last_name { 'LastName' }
      email { 'existing@example.com' }
    end

    factory :designer do
      first_name { 'FirstName' }
      last_name { 'LastName' }
      email { '' }
      designer { true }
    end

    factory :non_admin do
      first_name { 'FirstName' }
      last_name { 'LastName' }
      admin { false }
    end
  end
end
