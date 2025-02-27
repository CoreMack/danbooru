require 'test_helper'

module Sources
  class HentaiFoundryTest < ActiveSupport::TestCase
    context "The source for a hentai foundry picture" do
      setup do
        @image_1 = Source::Extractor.find("https://www.hentai-foundry.com/pictures/user/Afrobull/795025/kuroeda")
        @image_2 = Source::Extractor.find("https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png")
      end

      should "get the illustration id" do
        assert_equal("795025", @image_1.illust_id)
        assert_equal("795025", @image_2.illust_id)
      end

      should "get the artist name" do
        assert_equal("Afrobull", @image_1.artist_name)
        assert_equal("Afrobull", @image_2.artist_name)
      end

      should "get the artist commentary title" do
        assert_equal("kuroeda", @image_1.artist_commentary_title)
        assert_equal("kuroeda", @image_2.artist_commentary_title)
      end

      should "get profile url" do
        assert_equal("https://www.hentai-foundry.com/user/Afrobull", @image_1.profile_url)
        assert_equal("https://www.hentai-foundry.com/user/Afrobull", @image_2.profile_url)
      end

      should "get the image url" do
        assert_equal(["https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png"], @image_1.image_urls)
        assert_equal(["https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png"], @image_2.image_urls)
      end

      should "download an image" do
        assert_downloaded(1_349_887, @image_1.image_urls.sole)
        assert_downloaded(1_349_887, @image_2.image_urls.sole)
      end

      should "get the tags" do
        assert_equal([["elf", "https://www.hentai-foundry.com/search/index?query=elf&search_in=keywords"]], @image_1.tags)
        assert_equal([["elf", "https://www.hentai-foundry.com/search/index?query=elf&search_in=keywords"]], @image_2.tags)
      end

      should "find the correct artist" do
        @artist = FactoryBot.create(:artist, name: "Afrobull", url_string: @image_1.url)
        assert_equal([@artist], @image_1.artists)
        assert_equal([@artist], @image_2.artists)
      end
    end

    context "An artist profile url" do
      setup do
        @site = Source::Extractor.find("https://www.hentai-foundry.com/user/Afrobull/profile")
      end

      should "get the profile url" do
        assert_equal("https://www.hentai-foundry.com/user/Afrobull", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("Afrobull", @site.artist_name)
      end
    end

    context "A deleted picture" do
      setup do
        @image = Source::Extractor.find("https://www.hentai-foundry.com/pictures/user/faustsketcher/279498")
        @artist = FactoryBot.create(:artist, name: "faustsketcher", url_string: @image.url)
      end

      should "still find the artist name" do
        assert_equal("faustsketcher", @image.artist_name)
        assert_equal("https://www.hentai-foundry.com/user/faustsketcher", @image.profile_url)
        assert_equal([@artist], @image.artists)
      end
    end

    context "generating page urls" do
      should "work" do
        source1 = "http://pictures.hentai-foundry.com//a/AnimeFlux/219123.jpg"
        source2 = "http://pictures.hentai-foundry.com/a/AnimeFlux/219123/Mobile-Suit-Equestria-rainbow-run.jpg"
        source3 = "http://www.hentai-foundry.com/pictures/user/Ganassa/457176/LOL-Swimsuit---Caitlyn-reworked-nude-ver."

        assert_equal("https://www.hentai-foundry.com/pictures/user/AnimeFlux/219123", Source::URL.page_url(source1))
        assert_equal("https://www.hentai-foundry.com/pictures/user/AnimeFlux/219123", Source::URL.page_url(source2))
        assert_equal("https://www.hentai-foundry.com/pictures/user/Ganassa/457176", Source::URL.page_url(source3))
        assert_nil(Source::URL.page_url("https://pictures.hentai-foundry.com/a/AnimeFlux"))
      end
    end

    context "a post with a deeply nested commentary" do
      should "work" do
        @source = Source::Extractor.find("https://hentai-foundry.com/pictures/user/LumiNyu/867562/Mona-patreon-winner")
        assert_nothing_raised { @source.to_h }
      end
    end
  end
end
