part of 'views.dart';

String _resetPasswordScript(String endpoint, String token, String email) {
  return '''
(function () {
  const params = new URLSearchParams(window.location.search);
  const token = params.get('token') || ${jsonEncode(token)};
  const email = params.get('email') || ${jsonEncode(email)};
  const form = document.getElementById('reset-form');
  const message = document.getElementById('message');
  const emailInput = document.getElementById('email');
  const submitButton = form.querySelector('button[type="submit"]');
  const buttonText = document.getElementById('button-text');

  function showMessage(text, className) {
    message.textContent = text;
    message.className = 'message ' + className;
  }

  if (!token || !email) {
    form.hidden = true;
    showMessage('Invalid or expired reset link.', 'error');
    return;
  }

  emailInput.value = email;

  form.querySelectorAll('.toggle').forEach(function (button) {
    button.addEventListener('click', function () {
      const input = document.getElementById(button.dataset.toggle);
      const show = input.type === 'password';
      input.type = show ? 'text' : 'password';
      button.textContent = show ? 'Hide' : 'Show';
      button.setAttribute('aria-pressed', show ? 'true' : 'false');
    });
  });

  form.addEventListener('submit', async function (event) {
    event.preventDefault();
    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirm-password').value;

    if (password.length < 8) {
      showMessage('Password must be at least 8 characters long.', 'error');
      return;
    }
    if (password !== confirmPassword) {
      showMessage('Passwords do not match.', 'error');
      return;
    }

    submitButton.disabled = true;
    buttonText.textContent = 'Resetting...';

    try {
      const response = await fetch(${jsonEncode(endpoint)}, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({token: token, new_password: password})
      });

      if (response.ok) {
        form.hidden = true;
        showMessage('Password reset successfully.', 'success');
        return;
      }

      const errorBody = await response.json().catch(function () { return {}; });
      const messageText =
        errorBody && errorBody.error && errorBody.error.message
          ? errorBody.error.message
          : 'Failed to reset password. Please try again.';
      showMessage(messageText, 'error');
    } catch (_) {
      showMessage('Network error. Please try again.', 'error');
    } finally {
      submitButton.disabled = false;
      buttonText.textContent = 'Reset Password';
    }
  });
})();
''';
}

String _confirmMailScript(String endpoint, String token, String email) {
  return '''
(async function () {
  const params = new URLSearchParams(window.location.search);
  const token = params.get('token') || ${jsonEncode(token)};
  const email = params.get('email') || ${jsonEncode(email)};
  const message = document.getElementById('message');

  function showMessage(text, className) {
    message.textContent = text;
    message.className = 'message ' + className;
  }

  if (!token || !email) {
    showMessage('Invalid confirmation link.', 'error');
    return;
  }

  try {
    const response = await fetch(${jsonEncode(endpoint)}, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({token: token})
    });

    if (response.ok) {
      showMessage('Email confirmed successfully.', 'success');
    } else {
      showMessage('Failed to confirm email. Please try again.', 'error');
    }
  } catch (_) {
    showMessage('Failed to confirm email. Please try again.', 'error');
  }
})();
''';
}
