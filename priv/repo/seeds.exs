# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EmailIa.Repo.insert!(%EmailIa.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias EmailIa.Repo
alias EmailIa.User
alias EmailIa.Categories.Category
alias EmailIa.GoogleAccounts.GoogleAccount
alias EmailIa.Emails.Email

# Clear existing data
Repo.delete_all(Email)
Repo.delete_all(GoogleAccount)
Repo.delete_all(Category)
Repo.delete_all(User)

# Generate fake users
users = [
  %{
    email: "john.doe@example.com",
    name: "John Doe",
    image:
      "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
    provider: "google",
    provider_uid: "google_123456789"
  },
  %{
    email: "jane.smith@example.com",
    name: "Jane Smith",
    image:
      "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
    provider: "google",
    provider_uid: "google_987654321"
  },
  %{
    email: "mike.wilson@example.com",
    name: "Mike Wilson",
    image:
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
    provider: "google",
    provider_uid: "google_456789123"
  },
  %{
    email: "sarah.johnson@example.com",
    name: "Sarah Johnson",
    image:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
    provider: "google",
    provider_uid: "google_789123456"
  },
  %{
    email: "david.brown@example.com",
    name: "David Brown",
    image:
      "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face",
    provider: "google",
    provider_uid: "google_321654987"
  }
]

# Insert users
inserted_users =
  Enum.map(users, fn user_attrs ->
    Repo.insert!(%User{
      id: Ecto.UUID.generate(),
      email: user_attrs.email,
      name: user_attrs.name,
      image: user_attrs.image,
      provider: user_attrs.provider,
      provider_uid: user_attrs.provider_uid
    })
  end)

# Generate categories for each user
categories_data = [
  %{name: "Work", description: "Professional emails and work-related communications"},
  %{name: "Personal", description: "Personal emails from friends and family"},
  %{name: "Newsletters", description: "Newsletters and subscriptions"},
  %{name: "Shopping", description: "Online shopping confirmations and deals"},
  %{name: "Finance", description: "Bank statements, bills, and financial updates"},
  %{name: "Travel", description: "Travel bookings and itineraries"},
  %{name: "Social", description: "Social media notifications and updates"},
  %{name: "Spam", description: "Unwanted promotional emails"}
]

# Insert categories for each user
inserted_categories =
  Enum.flat_map(inserted_users, fn user ->
    Enum.map(categories_data, fn category_attrs ->
      Repo.insert!(%Category{
        id: Ecto.UUID.generate(),
        name: category_attrs.name,
        description: category_attrs.description,
        user_id: user.id
      })
    end)
  end)

# Generate Google accounts for each user
google_accounts_data = [
  %{email: "john.doe@gmail.com"},
  %{email: "jane.smith@gmail.com"},
  %{email: "mike.wilson@gmail.com"},
  %{email: "sarah.johnson@gmail.com"},
  %{email: "david.brown@gmail.com"}
]

# Insert Google accounts
inserted_google_accounts =
  Enum.map(Enum.zip(inserted_users, google_accounts_data), fn {user, account_attrs} ->
    Repo.insert!(%GoogleAccount{
      id: Ecto.UUID.generate(),
      email: account_attrs.email,
      access_token: "ya29.a0AfH6SMC" <> String.duplicate("x", 100),
      refresh_token: "1//04dX" <> String.duplicate("x", 50),
      token_expiry:
        DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second),
      user_id: user.id
    })
  end)

# Generate fake emails
email_subjects = [
  "Meeting Reminder: Project Review Tomorrow",
  "Your order #12345 has been shipped",
  "Weekly Newsletter: Tech Updates",
  "Payment confirmation for your subscription",
  "Flight confirmation: LAX to JFK",
  "New message from LinkedIn",
  "Your monthly statement is ready",
  "Welcome to our platform!",
  "Password reset requested",
  "Your account has been updated",
  "Special offer: 50% off this weekend",
  "Invoice #INV-2024-001",
  "Your delivery is on the way",
  "Security alert: New login detected",
  "Thank you for your purchase"
]

email_senders = [
  "noreply@company.com",
  "support@service.com",
  "newsletter@tech.com",
  "billing@platform.com",
  "notifications@social.com",
  "security@bank.com",
  "marketing@store.com",
  "team@startup.com",
  "help@app.com",
  "info@travel.com"
]

email_snippets = [
  "Hi there, just a quick reminder about our meeting tomorrow at 2 PM.",
  "Your order has been processed and is now on its way to you.",
  "This week's top stories in technology and innovation.",
  "We've received your payment of $29.99 for your monthly subscription.",
  "Your flight from Los Angeles to New York has been confirmed.",
  "You have a new connection request on LinkedIn.",
  "Your monthly statement for January 2024 is now available.",
  "Welcome! We're excited to have you on board.",
  "We received a request to reset your password.",
  "Your account settings have been successfully updated.",
  "Don't miss out on our biggest sale of the year!",
  "Please find attached your invoice for services rendered.",
  "Your package is scheduled for delivery tomorrow.",
  "We detected a new login to your account from an unknown device.",
  "Thank you for your recent purchase. We hope you enjoy your new items."
]

ai_summaries = [
  "Meeting reminder for project review scheduled for tomorrow at 2 PM.",
  "Order confirmation with tracking information for shipped items.",
  "Weekly technology newsletter with industry updates and trends.",
  "Payment confirmation for monthly subscription renewal.",
  "Flight confirmation with itinerary details for upcoming travel.",
  "LinkedIn connection request from professional contact.",
  "Monthly financial statement available for review.",
  "Welcome email for new platform registration.",
  "Password reset request initiated for account security.",
  "Account settings update confirmation.",
  "Promotional offer with discount code for limited time.",
  "Invoice for services with payment details and due date.",
  "Delivery notification with tracking and estimated arrival.",
  "Security alert for suspicious account activity.",
  "Purchase confirmation with order details and receipt."
]

# Insert emails for each Google account
Enum.each(inserted_google_accounts, fn google_account ->
  # Get categories for this user
  user_categories =
    Enum.filter(inserted_categories, fn cat -> cat.user_id == google_account.user_id end)

  # Generate 20-30 emails per account
  Enum.each(1..Enum.random(20..30), fn _ ->
    subject = Enum.random(email_subjects)
    sender = Enum.random(email_senders)
    snippet = Enum.random(email_snippets)
    ai_summary = Enum.random(ai_summaries)
    category = Enum.random(user_categories)

    Repo.insert!(%Email{
      id: Ecto.UUID.generate(),
      message_id: ("msg_" <> Ecto.UUID.generate()) |> String.slice(0, 20),
      subject: subject,
      from: sender,
      to: google_account.email,
      snippet: snippet,
      ai_summary: ai_summary,
      original_body: """
      #{subject}

      #{snippet}

      This is a sample email body with some additional content to make it more realistic.
      It might contain links, formatting, and other elements that you'd find in a real email.

      Best regards,
      The Team
      """,
      unsubscribe_link: "https://unsubscribe.example.com/" <> Ecto.UUID.generate(),
      imported_at:
        DateTime.utc_now()
        |> DateTime.add(-Enum.random(1..30), :day)
        |> DateTime.truncate(:second),
      archived: Enum.random([true, false]),
      google_account_id: google_account.id,
      category_id: category.id
    })
  end)
end)

IO.puts("✅ Database seeded successfully!")
IO.puts("📊 Created:")
IO.puts("   - #{length(inserted_users)} users")
IO.puts("   - #{length(inserted_categories)} categories")
IO.puts("   - #{length(inserted_google_accounts)} Google accounts")
IO.puts("   - ~#{length(inserted_google_accounts) * 25} emails")
