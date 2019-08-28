require 'spec_helper'

describe ChecklistHelper, type: :helper do
  describe "#filter_actions" do
    let(:action1) { Checklists::Action.new('criteria' => []) }
    let(:action2) { Checklists::Action.new('criteria' => %w[A]) }
    let(:action3) { Checklists::Action.new('criteria' => %w[B C]) }
    let(:actions) { [action1, action2, action3] }

    subject { filter_actions(actions, criteria_keys) }

    context "when there is no criteria" do
      let(:criteria_keys) { [] }

      it "returns no actions" do
        expect(subject).to eq([])
      end
    end

    context "when there is a criteria" do
      let(:criteria_keys) { %w[A] }

      it "returns some actions" do
        expect(subject).to eq([action2])
      end
    end

    context "when there is multiple criteria" do
      let(:criteria_keys) { %w[A B] }

      it "returns some actions" do
        expect(subject).to eq([action2, action3])
      end
    end
  end

  describe "#format_action_audiences" do
    let(:action1) { Checklists::Action.new('audience' => 'citizen', 'priority' => 'Medium') }
    let(:action2) { Checklists::Action.new('audience' => 'citizen', 'priority' => 'High') }
    let(:action3) { Checklists::Action.new('audience' => 'business', 'priority' => 'Medium') }
    let(:action4) { Checklists::Action.new('audience' => 'business', 'priority' => 'Medium') }

    subject { format_action_audiences(actions) }

    context "when there are actions for each audience" do
      let(:actions) { [action1, action2, action3, action4] }

      it "return actions grouped by audience and sorted by priority" do
        expect(subject).to eq([
          {
            heading: I18n.t("checklists_results.audiences.citizen.heading"),
            actions: [action2, action1]
          },
          {
            heading: I18n.t("checklists_results.audiences.business.heading"),
            actions: [action3, action4]
          }
        ])
      end
    end
  end
end
