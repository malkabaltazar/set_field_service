require "set_field_service"
require "spec_helper"

describe ProspectManagement::SetFieldService do
  before(:all) do
    create_prospects_table
    @prospect = Class.new(ActiveRecord::Base) { self.table_name = "prospects" }
    @prospect1 = @prospect.create(email: "foo@example.com")
  end

  after(:all) do
    drop_table("prospects")
  end

  describe ".call" do
    context "given blank email" do
      it "returns error" do
        call = ProspectManagement::SetFieldService.new.call(logon: "foo", prospect: @prospect1, field_name: "email", newvalue: "  ")
        error = Hash[:error, 'You need to specify an email for this prospect.']
        expect(call).to eq(error)
      end
    end

    context "given invalid email" do
      it "returns error" do
        call = ProspectManagement::SetFieldService.new.call(logon: "foo", prospect: @prospect1, field_name: "email", newvalue: "foo")
        error = Hash[:error, "Can't save email. Invalid value: 'foo'"]
        expect(call).to eq(error)
      end
    end

    context "given non unique email" do
      it "returns error" do
        call = ProspectManagement::SetFieldService.new.call(logon: "foo", prospect: @prospect.new, field_name: "email", newvalue: "foo@example.com")
        error = Hash[:error, "Email already exists."]
        expect(call).to eq(error)
      end
    end

    context "given email and StandardError raised" do
      it "returns error as hash" do
        prospect_double = object_double(@prospect1, "email=" => true, "verified=" => true)
        allow(prospect_double).to receive(:save!).and_raise(StandardError, "An error message")
        
        call = ProspectManagement::SetFieldService.new.call(logon: "foo", prospect: prospect_double, field_name: "email", newvalue: "baz@example.com")
        error = Hash[:error, "An error message"]
        expect(call).to eq(error)
      end
    end

    context "given valid email" do
      it "updates record email and verified status" do
        ProspectManagement::SetFieldService.new.call(logon: "foo", prospect: @prospect1, field_name: "email", newvalue: "bar@example.com")
        expect(@prospect1.email).to eq("bar@example.com")
        expect(@prospect1.verified).to eq(0)
      end
    end

    context "given first_name, last_name, phone, title or role" do
      it "updates record" do
        ProspectManagement::SetFieldService.new.call(logon: "foo", prospect: @prospect1, field_name: "first_name", newvalue: " John ")
        expect(@prospect1.first_name).to eq("John")
      end
    end

    context "given score" do
      it "updates record" do
        ProspectManagement::SetFieldService.new.call(logon: "foo", prospect: @prospect1, field_name: "score", newvalue: "10")
        expect(@prospect1.score).to eq(10)
      end
    end

    context "given unknown field" do
      it "returns error" do
        call = ProspectManagement::SetFieldService.new.call(logon: "foo", prospect: @prospect1, field_name: "verified", newvalue: true)
        error = Hash[:error, "Unknown field: 'verified'"]
        expect(call).to eq(error)
      end
    end
  end
end
