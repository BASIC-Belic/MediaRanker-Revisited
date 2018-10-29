require 'test_helper'

# Tests rendering, routing, and HTTP status when appropriate
# Tests updates to the model when appropriate
# Tests custom controller logic and custom routes when appropriate
# Tests positive, negative, nominal and edge cases


describe WorksController do

  before do
    @book = works(:poodr)
    @movie = works(:movie)
    @album = works(:album)
    @user = users(:dan)
  end

  let(:bogus_work_id) { Work.first.destroy.id }


  describe "root" do

    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      @book.category = 'movie'

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do

      @book.destroy
      @movie.destroy
      @album.destroy

      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  let (:logged_in_user) {
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(@user))

    get auth_callback_path(:github)
  }

  describe "index" do
    it "succeeds when there are works" do

      logged_in_user

      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do

      logged_in_user

      @book.destroy
      @movie.destroy
      @album.destroy

      get works_path
      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds" do

      logged_in_user

      get new_work_path(@book.id)
      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do

      logged_in_user

      work_data = {
        work:
        { title: "Unique Title", category: 'book' }
      }

      test_work = Work.new(work_data[:work])
      test_work.must_be :valid?, "Work data was invalid. Please come fix this test."

      expect {
        post works_path params: work_data
      }.must_change 'Work.count', +1

      must_redirect_to work_path(Work.last)
    end

    it "renders bad_request and does not update the DB for bogus data" do

      logged_in_user

      work_data = {
        work:
        { category: 'movie' }
      }

      test_work = Work.new(work_data[:work])
      test_work.must_be :invalid?, "Work data was valid. Please come fix this test."

      expect {
        post works_path params: work_data
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do

      logged_in_user

      work_data = {
        work:
        { category: 'bogus movie' }
      }

      test_work = Work.new(work_data[:work])
      test_work.must_be :invalid?, "Work data was valid. Please come fix this test."

      expect {
        post works_path params: work_data
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do

      logged_in_user

      get work_path(@book)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do

      logged_in_user

      get work_path(bogus_work_id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do

      logged_in_user

      get edit_work_path(@book)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do

      logged_in_user

      get edit_work_path(bogus_work_id)
      must_respond_with :not_found
    end
  end


  # work_data = {
  #   work:
  #   { title: "Unique Title", category: 'book' }
  #   }
  #
  # test_work = Work.new(work_data[:work])
  # test_work.must_be :valid?, "Work data was invalid. Please come fix this test."
  #
  # expect {
  #   post works_path params: work_data
  # }.must_change 'Work.count', +1
  #
  # must_redirect_to work_path(Work.last)

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

      logged_in_user

      updated_work_data = {
        work:
        { title: @movie.title }
      }

      expect{
        put work_path(@book), params: updated_work_data
      }.wont_change 'Work.count'

      must_redirect_to work_path(@book)
    end

    it "renders bad_request for bogus data" do

      logged_in_user

      bogus_work_data = {
        work:
        { title: nil }
      }

      expect{
        put work_path(@book), params: bogus_work_data
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 404 not_found for a bogus work ID" do

      logged_in_user

      destroyed_work_id = bogus_work_id

      expect{
        put work_path(destroyed_work_id)
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do

      logged_in_user

      expect {
        delete work_path(@book)
      }.must_change 'Work.count', -1

      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do

      logged_in_user

      destroyed_work_id = bogus_work_id

      expect{
        delete work_path(destroyed_work_id)
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is #logged in" do

    end

    it "redirects to the work page after the user has #logged out" do

    end

    it "succeeds for a #logged-in user and a fresh user-vote pair" do

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
