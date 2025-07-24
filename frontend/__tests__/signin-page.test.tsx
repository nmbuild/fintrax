import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

// 1️⃣ Mock next/image to render a basic <img>
jest.mock('next/image', () => ({
  __esModule: true,
  default: (props: any) => <img {...props} />,
}));

// 2️⃣ Mock Clerk components so they just render their children or a stub
jest.mock('@clerk/nextjs', () => ({
  __esModule: true,
  ClerkLoaded:    ({ children }: any) => <>{children}</>,
  ClerkLoading:   ({ children }: any) => <>{children}</>,
  SignIn:         (props: any) => <div data-testid="sign-in" {...props} />,
}));

// 3️⃣ Import the page under test
import Page from '../app/(auth)/sign-in/[[...sign-in]]/page'; // adjust path

describe('Sign-In Page', () => {
  it('renders welcome text, sign-in form, and logo', () => {
    render(<Page />);

    // Heading
    expect(screen.getByRole('heading', { name: /welcome back!/i })).toBeInTheDocument();

    // Sub-text
    expect(
      screen.getByText(/log in to get back to your dashboard!/i)
    ).toBeInTheDocument();

    // Stubbed SignIn component
    expect(screen.getByTestId('sign-in')).toBeInTheDocument();

    // Logo image from our Image mock
    expect(screen.getByRole('img', { name: /logo/i })).toBeInTheDocument();
  });
});
