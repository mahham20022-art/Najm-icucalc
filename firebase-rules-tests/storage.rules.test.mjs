// Security-rules tests for `storage.rules`, run against the Storage
// Emulator via `firebase emulators:exec`.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';

const projectId = 'demo-med100';
const rules = readFileSync('../storage.rules', 'utf8');

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    storage: { rules },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearStorage();
});

const alice = () => testEnv.authenticatedContext('alice').storage();
const bob = () => testEnv.authenticatedContext('bob').storage();

const smallImage = new Uint8Array([1, 2, 3, 4, 5]);
const overSizeImage = new Uint8Array(11 * 1024 * 1024); // > the 10MB cap

const imagePath = 'users/alice/notes/note1/images/img1.jpg';

async function seedImage() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.storage().ref(imagePath).put(smallImage, { contentType: 'image/jpeg' });
  });
}

describe('users/{userId}/notes/{noteId}/images/{imageFile}', () => {
  it('owner can upload a small image to their own path', async () => {
    await assertSucceeds(alice().ref(imagePath).put(smallImage, { contentType: 'image/jpeg' }));
  });

  it('a different user cannot upload to that path', async () => {
    await assertFails(bob().ref(imagePath).put(smallImage, { contentType: 'image/jpeg' }));
  });

  it('rejects a non-image content type', async () => {
    await assertFails(
      alice().ref(imagePath).put(smallImage, { contentType: 'application/pdf' }),
    );
  });

  it('rejects a file at or over the 10MB cap', async () => {
    await assertFails(
      alice().ref(imagePath).put(overSizeImage, { contentType: 'image/jpeg' }),
    );
  });

  it('owner can read their own uploaded image', async () => {
    await seedImage();
    await assertSucceeds(alice().ref(imagePath).getDownloadURL());
  });

  it('a different user cannot read it', async () => {
    await seedImage();
    await assertFails(bob().ref(imagePath).getDownloadURL());
  });

  it('owner can delete their own image', async () => {
    await seedImage();
    await assertSucceeds(alice().ref(imagePath).delete());
  });

  it('a different user cannot delete it', async () => {
    await seedImage();
    await assertFails(bob().ref(imagePath).delete());
  });
});

describe('topics/{topicId}/** (signed-URL-only premium content)', () => {
  it('is never directly readable or writable by any client', async () => {
    await assertFails(alice().ref('topics/t1/body.json').getDownloadURL());
    await assertFails(
      alice().ref('topics/t1/body.json').put(smallImage, { contentType: 'application/json' }),
    );
  });
});

describe('default deny', () => {
  it('an arbitrary unmatched path is fully closed', async () => {
    await assertFails(
      alice().ref('random/path.txt').put(smallImage, { contentType: 'text/plain' }),
    );
  });
});
