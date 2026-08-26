resources :projects do
  resource :custom_field_defaults,
           only:       [:update],
           controller: 'project_custom_field_defaults'
end