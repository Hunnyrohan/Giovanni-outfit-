import bcrypt from 'bcrypt';
import { prisma } from '../src/config/prisma.js';
import { env } from '../src/config/env.js';

const seed = async () => {
  const password = await bcrypt.hash('Password@12345', env.bcryptSaltRounds);

  await prisma.user.upsert({
    where: { email: 'demo@stylesense.ai' },
    update: {},
    create: {
      fullName: 'Demo User',
      email: 'demo@stylesense.ai',
      password,
      authProvider: 'LOCAL',
      isEmailVerified: true,
      emailVerifiedAt: new Date(),
      preference: {
        create: {
          preferredStyles: ['minimal', 'smart casual'],
          preferredColors: ['black', 'white', 'navy'],
          dislikedColors: [],
          weatherEnabled: true,
        },
      },
    },
  });
};

seed()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
