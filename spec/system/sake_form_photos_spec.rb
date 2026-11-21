require "rails_helper"

RSpec.describe "Sake Form Photos" do
  let(:user) { create(:user) }

  before do
    login_as(user)
    visit new_sake_path
    fill_in("sake_name", with: "生道井")
  end

  describe "file_field for photos" do
    context "with one photo" do
      before do
        photo1 = Rails.root.join("spec/system/files/sake_photo1.jpg")
        attach_file("sake_photos", photo1)
        click_button("form_submit")
      end

      it "makes a sake having one photo" do
        sake = sake_from_show_path(page.current_path)
        expect(sake.photos.length).to eq(1)
      end
    end

    context "with multiple photos" do
      before do
        photo1 = Rails.root.join("spec/system/files/sake_photo1.jpg")
        photo2 = Rails.root.join("spec/system/files/sake_photo2.jpg")
        attach_file("sake_photos", [photo1, photo2])
        click_button("form_submit")
      end

      it "makes a sake having two photos" do
        sake = sake_from_show_path(page.current_path)
        expect(sake.photos.length).to eq(2)
      end
    end

    context "without photos" do
      before do
        click_button("form_submit")
      end

      it "makes a sake not having any photos" do
        sake = sake_from_show_path(page.current_path)
        expect(sake.photos.length).to eq(0)
      end
    end
  end
end
