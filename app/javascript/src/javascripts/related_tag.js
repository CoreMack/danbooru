import SourceDataComponent from "./source_data_component.js";
import Utility from './utility';

let RelatedTag = {};

RelatedTag.initialize_all = function() {
  $(document).on("click.danbooru", ".related-tags-button", RelatedTag.on_click_related_tags_button);
  $(document).on("change.danbooru", ".related-tags input", RelatedTag.toggle_tag);
  $(document).on("click.danbooru", ".related-tags a", RelatedTag.toggle_tag);
  $(document).on("click.danbooru", "#show-related-tags-link", RelatedTag.show);
  $(document).on("click.danbooru", "#hide-related-tags-link", RelatedTag.hide);
  $(document).on("keyup.danbooru.relatedTags", "#post_tag_string", RelatedTag.update_selected);

  $(document).on("danbooru:update-source-data", RelatedTag.on_update_source_data);
  $(document).on("danbooru:open-post-edit-dialog", RelatedTag.hide);
  $(document).on("danbooru:close-post-edit-dialog", RelatedTag.show);

  // Initialize the recent/favorite/translated/artist tag columns once, the first time the related tags are shown.
  $(document).one("danbooru:show-related-tags", RelatedTag.initialize_recent_and_favorite_tags);
  $(document).one("danbooru:show-related-tags", SourceDataComponent.fetchData);

  // Show the related tags automatically when the "Edit" tab is opened, or by default on the uploads page.
  $(document).on("danbooru:open-post-edit-tab", RelatedTag.show);
  if ($("#c-uploads #a-show #p-single-asset-upload").length) {
    RelatedTag.show();
  }
}

RelatedTag.initialize_recent_and_favorite_tags = function(event) {
  $.get("/related_tag.js", { user_tags: true });
}

RelatedTag.on_click_related_tags_button = function (event) {
  $.get("/related_tag.js", { query: RelatedTag.current_tag(), category: $(event.target).data("category") });
  RelatedTag.show();
}

RelatedTag.on_update_source_data = function (event, { related_tags_html }) {
  $(".source-related-tags-columns").replaceWith(related_tags_html);
  RelatedTag.update_selected();
}

RelatedTag.current_tag = function() {
  // 1. abc def |  -> def
  // 2. abc def|   -> def
  // 3. abc de|f   -> def
  // 4. abc |def   -> def
  // 5. abc| def   -> abc
  // 6. ab|c def   -> abc
  // 7. |abc def   -> abc
  // 8. | abc def  -> abc

  var $field = $("#post_tag_string");
  var string = $field.val();
  var n = string.length;
  var a = $field.prop('selectionStart');
  var b = $field.prop('selectionStart');

  if ((a > 0) && (a < (n - 1)) && (!/\s/.test(string[a])) && (/\s/.test(string[a - 1]))) {
    // 4 is the only case where we need to scan forward. in all other cases we
    // can drag a backwards, and then drag b forwards.

    while ((b < n) && (!/\s/.test(string[b]))) {
      b++;
    }
  } else if (string.search(/\S/) > b) { // case 8
    b = string.search(/\S/);
    while ((b < n) && (!/\s/.test(string[b]))) {
      b++;
    }
  } else {
    while ((a > 0) && ((/\s/.test(string[a])) || (string[a] === undefined))) {
      a--;
      b--;
    }

    while ((a > 0) && (!/\s/.test(string[a - 1]))) {
      a--;
      b--;
    }

    while ((b < (n - 1)) && (!/\s/.test(string[b]))) {
      b++;
    }
  }

  b++;
  return string.slice(a, b);
}

RelatedTag.update_selected = function(e) {
  var current_tags = RelatedTag.current_tags();

  $(".related-tags li").each((_, li) => {
    let tag_name = $(li).text().trim().replace(/ /g, "_");

    if (current_tags.includes(tag_name)) {
      $(li).addClass("selected");
      $(li).find("input").prop("checked", true);
    } else {
      $(li).removeClass("selected");
      $(li).find("input").prop("checked", false);
    }
  });
}

RelatedTag.current_tags = function() {
  let tagString = $("#post_tag_string").val().toLowerCase();
  return Utility.splitWords(tagString);
}

RelatedTag.toggle_tag = function(e) {
  var $field = $("#post_tag_string");
  var tag = $(e.target).closest("li").text().trim().replace(/ /g, "_");

  if (RelatedTag.current_tags().includes(tag)) {
    var escaped_tag = Utility.regexp_escape(tag);
    $field.val($field.val().replace(new RegExp("(^|\\s)" + escaped_tag + "($|\\s)", "gi"), "$1$2"));
  } else {
    $field.val($field.val() + " " + tag);
  }
  $field.val($field.val().trim().replace(/ +/g, " ") + " ");

  RelatedTag.update_selected();

  // The timeout is needed on Chrome since it will clobber the field attribute otherwise
  setTimeout(function () { $field.prop('selectionStart', $field.val().length);}, 100);
  e.preventDefault();

  // Artificially trigger input event so the tag counter updates.
  $field.trigger("input");
}

RelatedTag.show = function(e) {
  $(document).trigger("danbooru:show-related-tags");
  $("#related-tags-container").removeClass("collapsed").addClass("visible");

  if (e) {
    e.preventDefault();
  }
}

RelatedTag.hide = function(e) {
  $("#related-tags-container").removeClass("visible").addClass("collapsed");

  if (e) {
    e.preventDefault();
  }
}

$(function() {
  RelatedTag.initialize_all();
});

export default RelatedTag

