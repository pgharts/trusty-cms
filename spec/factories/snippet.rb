FactoryBot.define do

  factory :snippet do
    name { 'test_snippet' }
    content { <<-CONTENT }
      <p>Snippet Stuff</p>
    CONTENT
  end

end
