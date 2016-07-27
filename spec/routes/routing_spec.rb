require 'rails_helper'

RSpec.describe "Routing" , type: :routing do

  describe "for albums as a top-level resource" do
    it { expect(get("/albums")).to route_to("albums#index") }
    it { expect(get("/albums?page=1")).to route_to(controller: "albums", action: "index", page: "1" ) }
    it { expect(post("/albums")).to route_to("albums#create") }
    it { expect(put("/albums/1")).to route_to(controller: "albums", action: "update", id: "1") }
    it { expect(delete("/albums/1")).to route_to(controller: "albums", action: "destroy", id: "1") }

  end

  describe "for photos as a top-level resource" do
    it "does not route POST /photos" do 
      expect(post("/photos")).not_to be_routable
    end

    it { expect(put("/photos/1")).to route_to(controller: "photos", action: "update", id: "1") }
    it { expect(delete("/photos/1")).to route_to(controller: "photos", action: "destroy", id: "1") }
  end

  describe "for photos as a nested resource" do
    it { expect(get("/albums/123/photos")).to route_to(controller: "photos", action: "index", album_id: "123"
    ) }

    it { expect(post("/albums/123/photos")).to route_to(controller: "photos", action: "create", album_id: "123")}
  end
end
