Privacy Policy
==============

**Effective date:** September 6, 2026

Unitary does not collect, store, or transmit any personal information about
you.  There are no accounts, no analytics, no advertising, no trackers, no
crash reporting, and no third-party SDKs of any kind.  Nothing you type into
the app is sent anywhere.

The current version of this policy is published at
<https://wisnij.github.io/unitary/privacy>.  The copy included in the app
describes the version of Unitary you have installed; if you are reading it
inside the app, the published copy may be newer.


What Unitary stores
-------------------

Unitary saves the following on your device only, so the app can pick up where
you left off:

- your settings (precision, notation, theme, evaluation mode)
- your worksheet entries and which worksheet was last open
- your history of successful conversions in freeform mode
- the most recently fetched currency exchange rates

This data never leaves your device.  It is not backed up to any service by
Unitary, it is not readable by the developer, and it is removed when you
uninstall the app.


Network access
--------------

Unitary works entirely offline.  It makes exactly one kind of network request:
fetching currency exchange rates from the [Frankfurter
API](https://frankfurter.dev) at `api.frankfurter.dev`.

This request happens automatically when the stored rates are more than a day
old, and when you refresh rates manually from Settings or the Currency
worksheet.  It is unauthenticated and carries no identifier of any kind: no
account, no device ID, no advertising ID, and none of your conversions,
expressions, or settings.  It asks only for the current rate table.

It is still a network request, so it cannot be invisible.  As with any request
to any server, the operator of the Frankfurter API can see your device's IP
address and the time of the request.  Unitary has no control over what that
operator does with that information; see their own site for their practices.


Using Unitary in a web browser
------------------------------

Unitary is also published as a web app at
<https://wisnij.github.io/unitary/>.  That version behaves identically, and
stores its data in your browser's local storage rather than in app storage.

Because it is delivered over the web, it is served by GitHub Pages, and GitHub
records requests to it as any web host does.  That is a function of hosting,
not of Unitary, and it does not apply to the Android app you install from an
APK or from the Play Store.


Permissions
-----------

On Android, Unitary declares two permissions, neither of which grants access
to anything about you:

- `INTERNET`, used only for the exchange-rate request described above.
- `dev.wisnij.unitary.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, declared by
  the Flutter framework so the app can register its own private broadcast
  receivers on newer Android versions.  It is scoped to Unitary itself and
  conveys no access to anything outside the app.

Unitary requests no access to your location, contacts, camera, microphone,
files, or any other sensitive data, and it has no ability to do so.


Children
--------

Unitary is a unit conversion calculator suitable for all ages.  It collects no
data from anyone, including children.


Changes to this policy
----------------------

If this policy changes, the revised version is published at the address above
with an updated effective date, and it accompanies the release whose behaviour
it describes.


Contact
-------

Questions about this policy can be sent to Jim Wisniewski at
<wisnij@gmail.com>, or raised as an issue at
<https://github.com/wisnij/unitary/issues>.
