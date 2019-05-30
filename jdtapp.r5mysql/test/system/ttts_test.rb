require "application_system_test_case"

class TttsTest < ApplicationSystemTestCase
  setup do
    @ttt = ttts(:one)
  end

  test "visiting the index" do
    visit ttts_url
    assert_selector "h1", text: "Ttts"
  end

  test "creating a Ttt" do
    visit ttts_url
    click_on "New Ttt"

    fill_in "Name", with: @ttt.name
    click_on "Create Ttt"

    assert_text "Ttt was successfully created"
    click_on "Back"
  end

  test "updating a Ttt" do
    visit ttts_url
    click_on "Edit", match: :first

    fill_in "Name", with: @ttt.name
    click_on "Update Ttt"

    assert_text "Ttt was successfully updated"
    click_on "Back"
  end

  test "destroying a Ttt" do
    visit ttts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Ttt was successfully destroyed"
  end
end
