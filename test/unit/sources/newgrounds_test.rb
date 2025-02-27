require 'test_helper'

module Sources
  class NewgroundsTest < ActiveSupport::TestCase
    context "The source for a newgrounds picture" do
      setup do
        @url = "https://www.newgrounds.com/art/view/hcnone/sephiroth"
        @image_url = "https://art.ngfiles.com/images/1539000/1539538_hcnone_sephiroth.png?f1607668234"
        @image_1 = Source::Extractor.find(@url)
        @image_2 = Source::Extractor.find(@image_url)
      end

      should "get the artist name" do
        assert_equal("hcnone", @image_1.artist_name)
        assert_equal("hcnone", @image_2.artist_name)
      end

      should "get the artist commentary title" do
        assert_equal("Sephiroth", @image_1.artist_commentary_title)
        assert_equal("Sephiroth", @image_2.artist_commentary_title)
      end

      should "get profile url" do
        assert_equal("https://hcnone.newgrounds.com", @image_1.profile_url)
        assert_equal("https://hcnone.newgrounds.com", @image_2.profile_url)
      end

      should "get the image urls" do
        assert_equal([@image_url], @image_1.image_urls)
        assert_equal([@image_url], @image_2.image_urls)
      end

      should "get the page url" do
        assert_equal(@url, @image_1.page_url)
        assert_equal(@url, @image_2.page_url)
      end

      should "download an image" do
        assert_downloaded(4224, @image_1.image_urls.sole)
        assert_downloaded(4224, @image_2.image_urls.sole)
      end

      should "get the tags" do
        tags = [
          %w[sephiroth https://www.newgrounds.com/search/conduct/art?match=tags&tags=sephiroth],
          %w[supersmashbros https://www.newgrounds.com/search/conduct/art?match=tags&tags=supersmashbros],
        ]

        assert_equal(tags, @image_1.tags)
        assert_equal(tags, @image_2.tags)
      end

      should "find the right artist" do
        artist_1 = create(:artist, name: "hcnone1", url_string: "https://hcnone.newgrounds.com/art")
        artist_2 = create(:artist, name: "hcnone2", url_string: "https://www.newgrounds.com/art/view/hcnone/sephiroth")
        artist_3 = create(:artist, name: "bad_artist", url_string: "https://www.newgrounds.com/art")

        assert_equal([artist_1, artist_2], @image_1.artists)
        assert_equal([artist_1, artist_2], @image_2.artists)

        assert_not_equal([artist_3], @image_1.artists)
      end
    end

    context "A multi-image Newgrounds post" do
      should "get all the images" do
        source = Source::Extractor.find("https://www.newgrounds.com/art/view/natthelich/weaver")
        image_urls = [
          "https://art.ngfiles.com/images/1520000/1520217_natthelich_weaver.jpg?f1606365031",
          "https://art.ngfiles.com/comments/199000/iu_199826_7115981.jpg",
        ]

        assert_equal(image_urls, source.image_urls)
      end
    end

    context "A deleted or not existing picture" do
      setup do
        @fake_1 = Source::Extractor.find("https://www.newgrounds.com/art/view/ThisUser/DoesNotExist")
        @artist_1 = create(:artist, name: "thisuser", url_string: "https://thisuser.newgrounds.com")

        @fake_2 = Source::Extractor.find("https://www.newgrounds.com/art/view/natthelich/nopicture")
        @artist_2 = create(:artist, name: "natthelich", url_string: "https://natthelich.newgrounds.com")

        @fake_3 = Source::Extractor.find("https://www.newgrounds.com/art/view/theolebrave/sensitive-pochaco")
        @artist_3 = create(:artist, name: "taffytoad", url_string: "https://taffytoad.newgrounds.com")
      end

      should "still find the artist name" do
        assert_equal("thisuser", @fake_1.artist_name)
        assert_equal([@artist_1], @fake_1.artists)
        assert_equal("https://thisuser.newgrounds.com", @fake_1.profile_url)

        assert_equal("natthelich", @fake_2.artist_name)
        assert_equal([@artist_2], @fake_2.artists)

        assert_equal([@artist_3], @fake_3.artists)
      end
    end

    context "generating page urls" do
      should "work" do
        assert_equal("https://www.newgrounds.com/art/view/natthelich/fire-emblem-marth-plus-progress-pic", Source::URL.page_url("https://art.ngfiles.com/images/1033000/1033622_natthelich_fire-emblem-marth-plus-progress-pic.png?f1569487181"))
        assert_nil(Source::URL.page_url("https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg"))
      end
    end
  end
end
