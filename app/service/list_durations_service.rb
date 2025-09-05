module Service
  class ListDurationsService

    def retrieve
      [
        { id: 0, name: 'Meses' },
        { id: 2, name: 'Días' },
        { id: 1, name: 'Horas' },
        { id: 3, name: 'Minutos' }
      ]
    end

  end
end
