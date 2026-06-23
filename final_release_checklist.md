# PetConnect Final Release Checklist

Date: 23 June 2026

Use this checklist before submitting PetConnect as the final project.

## Repository

- [ ] GitHub repository URL is included in the submission form.
- [ ] Working branch or tag is clear for the reviewer.
- [ ] No real `.env` files are committed.
- [ ] No Supabase service role key, database password, JWT secret, Google Client Secret, Netlify token or GitHub secret is committed.
- [ ] README and documentation links open correctly.

## Application

- [ ] Production app URL is included in the submission form.
- [ ] Production app opens without blank screen.
- [ ] Auth/login/register flow works.
- [ ] Google OAuth button is visible and redirect settings are verified.
- [ ] Feed, Pets and Walks screens work.
- [ ] Pet image upload works with a safe test image.
- [ ] Search and filters work.
- [ ] Mobile and desktop layouts are usable.
- [ ] `/api/health` returns a non-secret health response.

## Backend

- [ ] Supabase migrations are applied.
- [ ] RLS remains enabled.
- [ ] Storage bucket `pet-images` exists.
- [ ] Google Client Secret is stored only in Supabase/Google dashboards.
- [ ] No production data deletion or RLS disabling was performed for submission.

## CI/CD

- [ ] GitHub Actions latest validation run is green.
- [ ] Netlify production deploy is successful.
- [ ] Build secrets are stored only in GitHub/Netlify settings.

## Documentation

- [ ] [README.md](README.md) is final.
- [ ] [project_documentation.md](project_documentation.md) is final.
- [ ] [ai_development_process.md](ai_development_process.md) documents AI usage.
- [ ] [development_report.md](development_report.md) summarizes decisions, problems and solutions.
- [ ] [prompts.md](prompts.md) includes prompt categories and outcomes.
- [ ] [security_audit.md](security_audit.md) includes final security/performance audit.
- [ ] [docs/submission_package.md](docs/submission_package.md) is ready.
- [ ] [docs/screenshots/README.md](docs/screenshots/README.md) is ready.

## Screenshots

- [ ] Landing/auth screen.
- [ ] Google OAuth button.
- [ ] Feed with posts.
- [ ] Create post form.
- [ ] Pets list.
- [ ] Pet image upload.
- [ ] Walks list.
- [ ] Filters/search.
- [ ] Final dark visual redesign.
- [ ] Mobile layout.
- [ ] GitHub Actions green run.
- [ ] Netlify production deploy.
- [ ] Supabase database tables.
- [ ] Supabase Storage bucket.
- [ ] Yandex Metrica overview without personal/private data.

## Final Safety Review

- [ ] Screenshots do not show service role key.
- [ ] Screenshots do not show Supabase access token.
- [ ] Screenshots do not show Google Client Secret.
- [ ] Screenshots do not show Netlify/GitHub secrets.
- [ ] Emails and personal data are blurred or avoided where needed.
