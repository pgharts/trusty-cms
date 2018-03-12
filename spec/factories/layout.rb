FactoryBot.define do

  factory :layout do
    name 'Main Layout'
    content <<-CONTENT
    <html>
      <head>
        <title><r:title /></title>
      </head>
      <body>
        <r:content />
      </body>
    </html>
        CONTENT
  end

end
