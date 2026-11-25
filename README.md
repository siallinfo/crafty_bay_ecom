# CraftyBay E-commerce

## Environment configuration

The app loads `API_BASE_URL` from the root `.env` file at startup. Copy
`.env.example` to `.env` before running the app; `.env` is excluded from Git.

Flutter bundles `.env` as an app asset, so its values can be extracted from the
installed application. Keep this file limited to public client configuration
such as the API base URL. Never put server secrets, private API keys, or user
credentials in it.

Customer authentication tokens are created at runtime and stored by the app;
they should not be added to `.env`.
