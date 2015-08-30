When(/^I ask if there are errors$/) do
  @csv_options ||= default_csv_options

  if @schema_json
    if @schema_type == :json_table
      @schema = Csvlint::Schema.from_json_table( @schema_url || "http://example.org ", JSON.parse(@schema_json) )
    else
      @schema = Csvlint::Schema.from_csvw_metadata( @schema_url || "http://example.org ", JSON.parse(@schema_json) )
    end
  end

  @validator = Csvlint::Validator.new( @url, @csv_options, @schema )
  @errors = @validator.errors
end

When(/^I carry out CSVW validation$/) do
  @csv_options ||= default_csv_options

  if @schema_json
    json = JSON.parse(@schema_json)
    if @schema_type == :json_table
      @schema = Csvlint::Schema.from_json_table( @schema_url || "http://example.org ", json )
    else
      @schema = Csvlint::Schema.from_csvw_metadata( @schema_url || "http://example.org ", json )
    end
  end

  if @url.nil?
    @errors = []
    @warnings = []
    @schema.tables.keys.each do |table_url|
      validator = Csvlint::Validator.new( table_url, @csv_options, @schema )
      @errors += validator.errors
      @warnings += validator.warnings
    end
  else
    validator = Csvlint::Validator.new( @url, @csv_options, @schema )
    @errors = validator.errors
    @warnings = validator.warnings
  end
end

Then(/^there should be errors$/) do
  expect( @errors.count ).to be > 0
end

Then(/^there should not be errors$/) do
  expect( @errors.count ).to eq(0)
  STDERR.puts @errors.inspect if @errors.count > 0
end

Then(/^there should be (\d+) error$/) do |count|
  expect( @errors.count ).to eq( count.to_i )
  STDERR.puts @errors.inspect if @errors.count > 0 && @errors.count != count.to_i
end

Then(/^that error should have the type "(.*?)"$/) do |type|
  expect( @errors.first.type ).to eq( type.to_sym )
end

Then(/^that error should have the row "(.*?)"$/) do |row|
  expect( @errors.first.row ).to eq( row.to_i )
end

Then(/^that error should have the column "(.*?)"$/) do |column|
  expect( @errors.first.column ).to eq( column.to_i )
end

Then(/^that error should have the content "(.*)"$/) do |content|
  expect( @errors.first.content.chomp ).to eq( content.chomp )
end

Then(/^that error should have no content$/) do
  expect( @errors.first.content ).to eq( nil )
end

Given(/^I have a CSV that doesn't exist$/) do
  @url = "http//www.example.com/fake-csv.csv"
  stub_request(:get, @url).to_return(:status => 404)
end

Then(/^there should be no "(.*?)" errors$/) do |type|
  @errors.each do |error| error.type.should_not == type.to_sym end
end
