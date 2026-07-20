import { createRootRoute, createRoute } from '@tanstack/react-router'
import { RootLayout } from './components/layout/RootLayout'
import { Home } from './pages/Home'
import { Quiz } from './pages/Quiz'
import { Results } from './pages/Results'
import { Login } from './pages/Login'
import { Signup } from './pages/Signup'
import { GarageHome } from './pages/garage/GarageHome'
import { BikeDetail } from './pages/garage/BikeDetail'

const rootRoute = createRootRoute({
  component: RootLayout,
})

const homeRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  component: Home,
})

const quizRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/quiz',
  component: Quiz,
})

const resultsRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/results',
  component: Results,
})

const loginRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/login',
  component: Login,
})

const signupRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/signup',
  component: Signup,
})

const garageRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/garage',
  component: GarageHome,
})

export const garageBikeRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/garage/bikes/$bikeId',
  component: BikeDetail,
})

export const routeTree = rootRoute.addChildren([
  homeRoute,
  quizRoute,
  resultsRoute,
  loginRoute,
  signupRoute,
  garageRoute,
  garageBikeRoute,
])
