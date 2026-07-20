import { Outlet } from '@tanstack/react-router'
import { NavBar } from './NavBar'

export function RootLayout() {
  return (
    <>
      <NavBar />
      <Outlet />
    </>
  )
}
