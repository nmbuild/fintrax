import { SignedIn, SignedOut, RedirectToSignIn, UserButton } from "@clerk/nextjs";

export default function hi() {
  return (
    // <>
    //   <SignedIn>
    //     <h1>Welcome to the Dashboard!</h1>
    //   </SignedIn>
    //   <SignedOut>
    //     <RedirectToSignIn />
    //   </SignedOut>
    // </>
    <UserButton/>
  );
}
