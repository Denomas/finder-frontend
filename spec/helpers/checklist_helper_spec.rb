require 'spec_helper'

describe ChecklistHelper, type: :helper do
  describe "#next_viewable_page" do
    let(:page) { 1 }
    let(:criteria_keys) { [1, 2, 3] }
    let(:questions) do
      [
        Checklists::Question.new('depends_on' => [1, 2, 3]),
        Checklists::Question.new('depends_on' => [1, 2, 3]),
        Checklists::Question.new('depends_on' => [1, 2, 3])
      ]
    end

    subject { next_viewable_page(page, questions, criteria_keys) }

    context "when its the first page and the question is not dependent" do
      it { is_expected.to eq(1) }
    end

    context "when the question's criteria are not met" do
      it 'returns the next page' do
        questions[0] = Checklists::Question.new('depends_on' => [4])
        expect(subject).to eq(2)
      end
    end

    context "when consecutive questions' criteria are not met" do
      it 'returns the page number of first applicable question' do
        questions[0] = Checklists::Question.new('depends_on' => [4])
        questions[1] = Checklists::Question.new('depends_on' => [4])
        expect(subject).to eq(3)
      end
    end

    context "when its the last page and question's criteria are not met" do
      let(:page) { 3 }

      it 'returns the next page' do
        questions[2] = Checklists::Question.new('depends_on' => [4])
        expect(subject).to eq(4)
      end
    end
  end

  describe "#filter_actions" do
    let(:action1) { Checklists::Action.new('applicable_criteria' => []) }
    let(:action2) { Checklists::Action.new('applicable_criteria' => %w[A]) }
    let(:action3) { Checklists::Action.new('applicable_criteria' => %w[B C]) }
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

  describe "#format_action_sections" do
    let(:citizen_action) { Checklists::Action.new('section' => 'citizen') }
    let(:business_action) { Checklists::Action.new('section' => 'business') }

    subject { format_action_sections(actions) }

    context "when there are actions for each section" do
      let(:actions) { [citizen_action, business_action] }
      it "return formatted sections" do
        expect(subject).to eq([
          {
            heading: I18n.t("checklists_results.sections.citizen.heading"),
            actions: [citizen_action]
          },
          {
            heading: I18n.t("checklists_results.sections.business.heading"),
            actions: [business_action]
          }
        ])
      end
    end

    context "when there are not actions" do
      let(:actions) { [] }
      it "returns no sections" do
        expect(subject).to eq([])
      end
    end
  end
end
