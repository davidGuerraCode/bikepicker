import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { api, queryKeys } from '../services/api'

export function useBikes() {
  return useQuery({
    queryKey: queryKeys.bikes,
    queryFn: () => api.getBikes().then(r => r.data),
  })
}

export function useBike(id: number) {
  return useQuery({
    queryKey: queryKeys.bike(id),
    queryFn: () => api.getBike(id).then(r => r.data),
    enabled: !!id,
  })
}

export function useCreateBike() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (attrs: { nickname?: string; brand: string; model: string; year?: number }) =>
      api.createBike(attrs).then(r => r.data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.bikes })
      queryClient.invalidateQueries({ queryKey: queryKeys.garageSummary })
    },
  })
}

export function useUpdateBike(id: number) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (attrs: Partial<{ nickname: string; brand: string; model: string; year: number }>) =>
      api.updateBike(id, attrs).then(r => r.data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.bikes })
      queryClient.invalidateQueries({ queryKey: queryKeys.bike(id) })
    },
  })
}

export function useExpenses(bikeId: number) {
  return useQuery({
    queryKey: queryKeys.expenses(bikeId),
    queryFn: () => api.getExpenses(bikeId).then(r => r.data),
    enabled: !!bikeId,
  })
}

export function useCreateExpense(bikeId: number) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (attrs: {
      category: string
      amount_cop: number
      spent_on: string
      description?: string
    }) => api.createExpense(bikeId, attrs).then(r => r.data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.expenses(bikeId) })
      queryClient.invalidateQueries({ queryKey: queryKeys.bikeSummary(bikeId) })
      queryClient.invalidateQueries({ queryKey: queryKeys.garageSummary })
    },
  })
}

export function useUpdateExpense(bikeId: number) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: ({
      id,
      attrs,
    }: {
      id: number
      attrs: Partial<{ category: string; amount_cop: number; spent_on: string; description: string }>
    }) => api.updateExpense(id, attrs).then(r => r.data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.expenses(bikeId) })
      queryClient.invalidateQueries({ queryKey: queryKeys.bikeSummary(bikeId) })
      queryClient.invalidateQueries({ queryKey: queryKeys.garageSummary })
    },
  })
}

export function useDeleteExpense(bikeId: number) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (id: number) => api.deleteExpense(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.expenses(bikeId) })
      queryClient.invalidateQueries({ queryKey: queryKeys.bikeSummary(bikeId) })
      queryClient.invalidateQueries({ queryKey: queryKeys.garageSummary })
    },
  })
}

export function useBikeSummary(bikeId: number) {
  return useQuery({
    queryKey: queryKeys.bikeSummary(bikeId),
    queryFn: () => api.getBikeSummary(bikeId).then(r => r.data),
    enabled: !!bikeId,
  })
}

export function useGarageSummary() {
  return useQuery({
    queryKey: queryKeys.garageSummary,
    queryFn: () => api.getGarageSummary().then(r => r.data),
  })
}
