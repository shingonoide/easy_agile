require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoriesController do

  before :each do
    login
    stub_projects!

    @story = mock_model Story
    @new_story = mock_model Story, :content= => ''
    @stories = mock('Collection', :build => @new_story, :find => @story)
    @project.stub!(:stories).and_return(@stories)
  end

  describe "instance variable setup" do
    before :each do
      controller.instance_variable_set('@project', @project)
    end

    describe "new_story" do
      before :each do
        controller.stub!(:params).and_return(:project_id => @project.id)
      end

      it "should set the project" do
        @stories.should_receive(:build)
        controller.send(:new_story)
      end

      it "should set the instance variable" do
        controller.send(:new_story)
        controller.instance_variable_get("@story").should == @new_story
      end
    end

    describe "get_story" do
      before :each do
        controller.stub!(:params).and_return(
          :project_id => @project.id,
          :id => @story.id
        )
      end

      it "should get the story from the project" do
        @stories.should_receive(:find).with(@story.id)
        controller.send(:get_story)
      end

      it "should set the instance variable" do
        controller.send(:get_story)
        controller.instance_variable_get("@story").should == @story
      end
    end
  end

  describe "it operates on a new story", :shared => true do
    it "should call new_story" do
      controller.should_receive(:new_story)
      do_call
    end
  end

  describe "it operates on an existing story", :shared => true do
    it "should call get_story" do
      controller.should_receive(:get_story)
      do_call
    end
  end

  describe "index" do
    def do_call
      get :index, :project_id => @project.id
    end

    before :each do
      controller.stub!(:get_project)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it's successful"
  end

  describe "new" do
    def do_call
      get :new, :project_id => @project.id
    end

    before :each do
      controller.stub!(:get_project)
      controller.stub!(:new_story)
      controller.instance_variable_set('@story', @new_story)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on a new story"
    it_should_behave_like "it's successful"

    it "should set a default story" do
      @new_story.should_receive(:content=)
      do_call
    end
  end

  describe "create" do
    def do_call
      post :create, :project_id => @project.id,
        :story => @attributes
    end

    before :each do
      controller.stub!(:get_project)
      controller.stub!(:new_story)

      controller.instance_variable_set('@project', @project)
      controller.instance_variable_set('@story', @story)

      @attributes = {
        'name' => 'User can log in',
        'content' => 'As a user I want to log in so that I can do stuff',
      }

      @story.stub!(:save)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on a new story"

    it "should attempt to save" do
      @story.should_receive(:save)
      do_call
    end

    describe "success" do
      before :each do
        @story.stub!(:save).and_return(true)
      end

      it "should redirect to show" do
        do_call
        response.should redirect_to(project_story_url(@project, @story))
      end

      it "should provide a flash notice" do
        do_call
        flash[:notice].should_not be_blank
      end
    end

    describe "failure" do
      before :each do
        @story.stub!(:save).and_return(false)
      end

      it "should re-render the new template" do
        do_call
        response.should render_template('stories/new')
      end
    end
  end

  describe "show" do
    def do_call
      get :show, :id => @story.id, :project_id => @project.id
    end

    before :each do
      controller.stub!(:get_story)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it operates on an existing story"
    it_should_behave_like "it's successful"
  end
end