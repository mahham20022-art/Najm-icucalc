// Security-rules tests for `firestore.rules`, run against the Firestore
// Emulator via `firebase emulators:exec` (see package.json's `test`
// script and the repo root README for the exact invocation). Never runs
// against production — `initializeTestEnvironment` refuses anything but
// a `demo-*` project id.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';

const projectId = 'demo-med100';
const rules = readFileSync('../firestore.rules', 'utf8');

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: { rules },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

const alice = () => testEnv.authenticatedContext('alice').firestore();
const bob = () => testEnv.authenticatedContext('bob').firestore();
const admin = () => testEnv.authenticatedContext('staffAdmin', { role: 'admin' }).firestore();
const editor = () => testEnv.authenticatedContext('staffEditor', { role: 'editor' }).firestore();
const anon = () => testEnv.unauthenticatedContext().firestore();

async function seed(fn) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await fn(context.firestore());
  });
}

describe('users/{userId}', () => {
  it('owner can read their own profile', async () => {
    await seed((db) => db.doc('users/alice').set({ uid: 'alice', role: 'learner' }));
    await assertSucceeds(alice().doc('users/alice').get());
  });

  it('another signed-in user cannot read a profile they do not own', async () => {
    await seed((db) => db.doc('users/alice').set({ uid: 'alice', role: 'learner' }));
    await assertFails(bob().doc('users/alice').get());
  });

  it('an unauthenticated request cannot read any profile', async () => {
    await seed((db) => db.doc('users/alice').set({ uid: 'alice', role: 'learner' }));
    await assertFails(anon().doc('users/alice').get());
  });

  it('staff (admin custom claim) can read any profile', async () => {
    await seed((db) => db.doc('users/alice').set({ uid: 'alice', role: 'learner' }));
    await assertSucceeds(admin().doc('users/alice').get());
  });

  it('staff (editor custom claim) can read any profile', async () => {
    await seed((db) => db.doc('users/alice').set({ uid: 'alice', role: 'learner' }));
    await assertSucceeds(editor().doc('users/alice').get());
  });

  it('owner can create their own profile with safe defaults', async () => {
    await assertSucceeds(
      alice()
        .doc('users/alice')
        .set({ uid: 'alice', role: 'learner', accountStatus: 'active', displayName: 'Alice' }),
    );
  });

  it('cannot create a profile for a different uid', async () => {
    await assertFails(
      bob().doc('users/alice').set({ uid: 'alice', role: 'learner', accountStatus: 'active' }),
    );
  });

  it('cannot self-assign a non-learner role at signup', async () => {
    await assertFails(
      alice()
        .doc('users/alice')
        .set({ uid: 'alice', role: 'admin', accountStatus: 'active' }),
    );
  });

  it('cannot self-assign an institutionId at signup', async () => {
    await assertFails(
      alice()
        .doc('users/alice')
        .set({
          uid: 'alice',
          role: 'learner',
          accountStatus: 'active',
          institutionId: 'inst-1',
        }),
    );
  });

  it('owner can update their own non-privileged fields', async () => {
    await seed((db) =>
      db.doc('users/alice').set({ uid: 'alice', role: 'learner', accountStatus: 'active' }),
    );
    await assertSucceeds(alice().doc('users/alice').update({ displayName: 'Alice Smith' }));
  });

  it('owner cannot escalate their own role via update', async () => {
    await seed((db) =>
      db.doc('users/alice').set({ uid: 'alice', role: 'learner', accountStatus: 'active' }),
    );
    await assertFails(alice().doc('users/alice').update({ role: 'admin' }));
  });

  it('owner cannot un-suspend their own account via update', async () => {
    await seed((db) =>
      db.doc('users/alice').set({ uid: 'alice', role: 'learner', accountStatus: 'suspended' }),
    );
    await assertFails(alice().doc('users/alice').update({ accountStatus: 'active' }));
  });

  it('admin can suspend a learner account (accountStatus only)', async () => {
    await seed((db) =>
      db.doc('users/alice').set({ uid: 'alice', role: 'learner', accountStatus: 'active' }),
    );
    await assertSucceeds(admin().doc('users/alice').update({ accountStatus: 'suspended' }));
  });

  it('admin cannot change role through the accountStatus escape hatch', async () => {
    await seed((db) =>
      db.doc('users/alice').set({ uid: 'alice', role: 'learner', accountStatus: 'active' }),
    );
    await assertFails(
      admin().doc('users/alice').update({ accountStatus: 'suspended', role: 'admin' }),
    );
  });

  it('delete is always denied, even for the owner', async () => {
    await seed((db) => db.doc('users/alice').set({ uid: 'alice', role: 'learner' }));
    await assertFails(alice().doc('users/alice').delete());
  });
});

describe('users/{userId}/notes (client-owned)', () => {
  it('owner can write their own note', async () => {
    await assertSucceeds(
      alice().doc('users/alice/notes/note1').set({ title: 'Hi', bodyMarkdown: 'x' }),
    );
  });

  it('another user cannot read or write it', async () => {
    await seed((db) => db.doc('users/alice/notes/note1').set({ title: 'Hi' }));
    await assertFails(bob().doc('users/alice/notes/note1').get());
    await assertFails(bob().doc('users/alice/notes/note1').set({ title: 'Hacked' }));
  });
});

describe('users/{userId}/teachingSessions (append-only)', () => {
  it('owner can create a session', async () => {
    await assertSucceeds(
      alice().doc('users/alice/teachingSessions/s1').set({ topicId: 't1', mode: 'written' }),
    );
  });

  it('staff can read a session, another learner cannot', async () => {
    await seed((db) => db.doc('users/alice/teachingSessions/s1').set({ topicId: 't1' }));
    await assertSucceeds(admin().doc('users/alice/teachingSessions/s1').get());
    await assertFails(bob().doc('users/alice/teachingSessions/s1').get());
  });

  it('the owner cannot edit or delete a session after it is created', async () => {
    await seed((db) => db.doc('users/alice/teachingSessions/s1').set({ topicId: 't1' }));
    await assertFails(alice().doc('users/alice/teachingSessions/s1').update({ topicId: 't2' }));
    await assertFails(alice().doc('users/alice/teachingSessions/s1').delete());
  });
});

describe('server-computed collections (progress/streaks/mastery)', () => {
  for (const sub of ['progress/topic1', 'streaks/track1', 'mastery/specialty1']) {
    it(`owner can read but never write users/alice/${sub}`, async () => {
      await seed((db) => db.doc(`users/alice/${sub}`).set({ value: 1 }));
      await assertSucceeds(alice().doc(`users/alice/${sub}`).get());
      await assertFails(alice().doc(`users/alice/${sub}`).set({ value: 2 }));
    });
  }

  it('quizAttempts: owner can create (append-only) but never update/delete', async () => {
    await assertSucceeds(
      alice().doc('users/alice/quizAttempts/a1').set({ topicId: 't1', selectedOption: 0 }),
    );
    await assertFails(alice().doc('users/alice/quizAttempts/a1').update({ selectedOption: 1 }));
    await assertFails(alice().doc('users/alice/quizAttempts/a1').delete());
  });
});

describe('users/{userId}/flashcardSchedule (client-owned deviation)', () => {
  it('owner can read and write their own schedule', async () => {
    await assertSucceeds(
      alice().doc('users/alice/flashcardSchedule/card1').set({ stage: 'newCard' }),
    );
    await assertSucceeds(
      alice().doc('users/alice/flashcardSchedule/card1').update({ stage: 'review7' }),
    );
  });

  it('another user cannot touch it', async () => {
    await seed((db) => db.doc('users/alice/flashcardSchedule/card1').set({ stage: 'newCard' }));
    await assertFails(bob().doc('users/alice/flashcardSchedule/card1').get());
  });
});

describe('users/{userId}/notificationLog', () => {
  it('is never client-created (server/FCM-authored only)', async () => {
    await assertFails(
      alice().doc('users/alice/notificationLog/n1').set({ title: 'Hi', readAt: null }),
    );
  });

  it('owner can mark it read but cannot touch other fields', async () => {
    await seed((db) =>
      db.doc('users/alice/notificationLog/n1').set({ title: 'Hi', readAt: null }),
    );
    await assertSucceeds(
      alice().doc('users/alice/notificationLog/n1').update({ readAt: Date.now() }),
    );
  });

  it('owner cannot rewrite the title while marking it read', async () => {
    await seed((db) =>
      db.doc('users/alice/notificationLog/n1').set({ title: 'Hi', readAt: null }),
    );
    await assertFails(
      alice()
        .doc('users/alice/notificationLog/n1')
        .update({ readAt: Date.now(), title: 'Rewritten' }),
    );
  });
});

describe('public content', () => {
  for (const path of ['topics/t1', 'flashcards/f1', 'mcqs/m1', 'achievements/ach1']) {
    it(`${path} is readable by anyone, including signed-out`, async () => {
      await seed((db) => db.doc(path).set({ title: 'x' }));
      await assertSucceeds(anon().doc(path).get());
    });

    it(`${path} can never be written by a client`, async () => {
      await assertFails(alice().doc(path).set({ title: 'hacked' }));
      await assertFails(admin().doc(path).set({ title: 'hacked' }));
    });
  }

  it('mcqAnswers is never readable, not even by staff or the doc owner conceptually', async () => {
    await seed((db) => db.doc('mcqAnswers/m1').set({ correctIndex: 2 }));
    await assertFails(alice().doc('mcqAnswers/m1').get());
    await assertFails(admin().doc('mcqAnswers/m1').get());
  });
});

describe('subscriptions/{userId}', () => {
  it('owner and staff can read; nobody can write, not even the owner or admin', async () => {
    await seed((db) => db.doc('subscriptions/alice').set({ tier: 'free' }));
    await assertSucceeds(alice().doc('subscriptions/alice').get());
    await assertSucceeds(admin().doc('subscriptions/alice').get());
    await assertFails(bob().doc('subscriptions/alice').get());
    await assertFails(alice().doc('subscriptions/alice').set({ tier: 'premium' }));
    await assertFails(admin().doc('subscriptions/alice').set({ tier: 'premium' }));
  });
});

describe('default deny', () => {
  it('an arbitrary unmatched top-level collection is fully closed', async () => {
    await assertFails(alice().doc('somethingNew/doc1').set({ x: 1 }));
    await assertFails(admin().doc('somethingNew/doc1').get());
  });
});
