$(function () {
  var isNotepadShowing = false;
  function displayNotepad(bool) {
    if (bool) {
      $("#panel").show();
      $("#rt_notepad_input").val("");
      $("#rt_notepad_input").focus();
    } else {
      $("#panel").hide();
    }
    isNotepadShowing = bool;
  }

  var isMorseShowing = false;
  function displayMorse(bool) {
    if (bool) {
      $("#morsePanel").show();
      $("#rt_morse_input").val("");
      $("#rt_morse_input").focus();
    } else {
      $("#morsePanel").hide();
    }
    isMorseShowing = bool;
  }

  var history = [];
  var historyIndex = 0;
  var radioHistory = [];
  var radioHistoryIndex = 0;

  displayNotepad(false);
  displayMorse(false);

  window.addEventListener("message", function (event) {
    var content;
    var range;

    if (event.data.action == "clear") {
      $("#rt_notepad_input").val("");
      $("#rt_morse_input").val("");
    }

    if (event.data.action == "newNote") {
      if (event.data.align == "right") {
        content = $(
          '<div class="container-desc" style="display: none; background: #' +
            event.data.bgcolor +
            " !important; color: #" +
            event.data.ftcolor +
            ' !important;"><div class="text">' +
            event.data.text +
            '</div><i class="fa-solid fa-delete-left"></i></div>'
        );
        $(".noteContainer").prepend(content);
      } else {
        content = $(
          '<div class="container-desc-left" style="display: none; background: #' +
            event.data.bgcolor +
            " !important; color: #" +
            event.data.ftcolor +
            ' !important;"><div class="text">' +
            event.data.text +
            '</div><i class="fa-solid fa-delete-left"></i></div>'
        );
        $(".noteContainer-left").prepend(content);
      }

      $(content).fadeIn(500);
    }

    if (event.data.action == "newMorse") {
      content = $(
        '<div class="container-morse" style="display: none; background: #' +
          event.data.bgcolor +
          " !important; color: #" +
          event.data.ftcolor +
          ' !important;"><div class="text-radio">' +
          event.data.text +
          '</div><i class="fa-solid fa-walkie-talkie radio"></i></div>'
      );

      $(".morseContainer").html(content);
      $(content).fadeIn(500).delay(15000).fadeOut(500);
    }

    if (event.data.action == "removeNote") {
      $(".noteContainer").children().last().remove();
      $(".noteContainer-left").children().last().remove();
    }

    if (event.data.type === "notepad") {
      displayNotepad(event.data.status);
    }
    if (event.data.type === "morse") {
      displayMorse(event.data.status);
    }
  });

  $("body").on("keyup", function (key) {
    if(key.code == "Delete")
    {
      console.log("Aaa")
    }
  });

  document.onkeydown = function (data) {
    console.log(data.code);
    if (!isNotepadShowing && data.code == "Delete") {
      displayNotepad(true);
    }

    if (
      (isNotepadShowing &&
        ((data.code == "Backspace" && $("#rt_notepad_input").val() == "") ||
          data.code == "Escape")) ||
      (isMorseShowing &&
        ((data.code == "Backspace" && $("#rt_morse_input").val() == "") ||
          data.code == "Escape"))
    ) {
      isNotepadShowing = false;
      isMorseShowing = false;
      $.post("http://rt_notepad/exit", JSON.stringify({}));
    }

    if (data.code == "Enter" || data.code == "NumpadEnter") {
      if (isNotepadShowing) {
        let inputValue = $("#rt_notepad_input").val();
        if (inputValue) {
          history.push(inputValue);
          historyIndex = history.length;
          $.post(
            "http://rt_notepad/main",
            JSON.stringify({ text: inputValue, mode: "notepad" })
          );
        }
      }
      if (isMorseShowing) {
        let inputValue = $("#rt_morse_input").val();
        if (inputValue) {
          radioHistory.push(inputValue);
          radioHistoryIndex = radioHistory.length;
          $.post(
            "http://rt_notepad/main",
            JSON.stringify({ text: inputValue, mode: "morse" })
          );
        }
      }
    }

    if (data.code == "ArrowUp") {
      if (isNotepadShowing) {
        historyIndex--;
        if (historyIndex <= 0) {
          historyIndex = 0;
        }

        $("#rt_notepad_input").val(history[historyIndex]);
      } else if (isMorseShowing) {
        radioHistoryIndex--;
        if (radioHistoryIndex <= 0) {
          radioHistoryIndex = 0;
        }

        $("#rt_morse_input").val(radioHistory[radioHistoryIndex]);
      }
    }

    if (data.code == "ArrowDown") {
      if (isNotepadShowing) {
        historyIndex++;
        if (historyIndex > history.length - 1) {
          historyIndex = history.length;
          $("#rt_notepad_input").val("");
        }
        console.log(historyIndex);
        $("#rt_notepad_input").val(history[historyIndex]);
      } else if (isMorseShowing) {
        radioHistoryIndex++;
        if (radioHistoryIndex > radioHistory.length - 1) {
          radioHistoryIndex = radioHistory.length;
          $("#rt_morse_input").val("");
        }
        $("#rt_morse_input").val(radioHistory[radioHistoryIndex]);
      }
    }
  };

  $("#close").click(function () {
    isNotepadShowing = false;
    isMorseShowing = false;
    $.post("http://rt_notepad/exit", JSON.stringify({}));
    return;
  });

  $("#submit").click(function () {
    if (isNotepadShowing) {
      let inputValue = $("#rt_notepad_input").val();

      if (!inputValue) {
        return;
      }

      $.post(
        "http://rt_notepad/main",
        JSON.stringify({ text: inputValue, mode: "notepad" })
      );
      $("#rt_notepad_input").val("");
    } else if (isMorseShowing) {
      let inputValue = $("#rt_morse_input").val();

      if (!inputValue) {
        return;
      }

      $.post(
        "http://rt_notepad/main",
        JSON.stringify({ text: inputValue, mode: "morse" })
      );
      $("#rt_morse_input").val("");
    }
    return;
  });
});
