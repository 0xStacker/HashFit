import { useState } from "react";
import "./DeliveryForm.css";

export type DeliveryDetails = {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  address: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
};

type DeliveryFormProps = {
  onSubmit: (details: DeliveryDetails) => void;
  initialDetails?: Partial<DeliveryDetails>;
};

export function DeliveryForm({
  onSubmit,
  initialDetails = {},
}: DeliveryFormProps) {
  const [details, setDetails] = useState<DeliveryDetails>({
    firstName: initialDetails.firstName || "",
    lastName: initialDetails.lastName || "",
    email: initialDetails.email || "",
    phone: initialDetails.phone || "",
    address: initialDetails.address || "",
    city: initialDetails.city || "",
    state: initialDetails.state || "",
    zipCode: initialDetails.zipCode || "",
    country: initialDetails.country || "",
  });

  const [errors, setErrors] = useState<Partial<DeliveryDetails>>({});

  // Check entry correctness
  const validateForm = (): boolean => {
    const newErrors: Partial<DeliveryDetails> = {};

    if (!details.firstName.trim())
      newErrors.firstName = "First name is required";
    if (!details.lastName.trim()) newErrors.lastName = "Last name is required";
    if (!details.email.trim()) {
      newErrors.email = "Email is required";
    } else if (!/\S+@\S+\.\S+/.test(details.email)) {
      newErrors.email = "Email is invalid";
    }
    if (!details.phone.trim()) newErrors.phone = "Phone number is required";
    if (!details.address.trim()) newErrors.address = "Address is required";
    if (!details.city.trim()) newErrors.city = "City is required";
    if (!details.state.trim()) newErrors.state = "State is required";
    if (!details.zipCode.trim()) newErrors.zipCode = "ZIP code is required";
    if (!details.country.trim()) newErrors.country = "Country is required";

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateForm()) {
      onSubmit(details);
    }
  };

  const handleChange =
    (field: keyof DeliveryDetails) =>
    (e: React.ChangeEvent<HTMLInputElement>) => {
      setDetails((prev) => ({ ...prev, [field]: e.target.value }));
      if (errors[field]) {
        setErrors((prev) => ({ ...prev, [field]: undefined }));
      }
    };

  return (
    <div className="delivery-form-container">
      <h3 className="delivery-form-title">Delivery Details</h3>
      <form onSubmit={handleSubmit} className="delivery-form">
        <div className="form-row">
          <div className="form-group">
            <label htmlFor="firstName">First Name *</label>
            <input
              type="text"
              id="firstName"
              value={details.firstName}
              onChange={handleChange("firstName")}
              className={errors.firstName ? "error" : ""}
            />
            {errors.firstName && (
              <span className="error-message">{errors.firstName}</span>
            )}
          </div>
          <div className="form-group">
            <label htmlFor="lastName">Last Name *</label>
            <input
              type="text"
              id="lastName"
              value={details.lastName}
              onChange={handleChange("lastName")}
              className={errors.lastName ? "error" : ""}
            />
            {errors.lastName && (
              <span className="error-message">{errors.lastName}</span>
            )}
          </div>
        </div>

        <div className="form-group">
          <label htmlFor="email">Email *</label>
          <input
            type="email"
            id="email"
            value={details.email}
            onChange={handleChange("email")}
            className={errors.email ? "error" : ""}
          />
          {errors.email && (
            <span className="error-message">{errors.email}</span>
          )}
        </div>

        <div className="form-group">
          <label htmlFor="phone">Phone Number *</label>
          <input
            type="tel"
            id="phone"
            value={details.phone}
            onChange={handleChange("phone")}
            className={errors.phone ? "error" : ""}
          />
          {errors.phone && (
            <span className="error-message">{errors.phone}</span>
          )}
        </div>

        <div className="form-group">
          <label htmlFor="address">Address *</label>
          <input
            type="text"
            id="address"
            value={details.address}
            onChange={handleChange("address")}
            placeholder="Street address, apartment, suite, etc."
            className={errors.address ? "error" : ""}
          />
          {errors.address && (
            <span className="error-message">{errors.address}</span>
          )}
        </div>

        <div className="form-row">
          <div className="form-group">
            <label htmlFor="city">City *</label>
            <input
              type="text"
              id="city"
              value={details.city}
              onChange={handleChange("city")}
              className={errors.city ? "error" : ""}
            />
            {errors.city && (
              <span className="error-message">{errors.city}</span>
            )}
          </div>
          <div className="form-group">
            <label htmlFor="state">State/Province *</label>
            <input
              type="text"
              id="state"
              value={details.state}
              onChange={handleChange("state")}
              className={errors.state ? "error" : ""}
            />
            {errors.state && (
              <span className="error-message">{errors.state}</span>
            )}
          </div>
        </div>

        <div className="form-row">
          <div className="form-group">
            <label htmlFor="zipCode">ZIP/Postal Code *</label>
            <input
              type="text"
              id="zipCode"
              value={details.zipCode}
              onChange={handleChange("zipCode")}
              className={errors.zipCode ? "error" : ""}
            />
            {errors.zipCode && (
              <span className="error-message">{errors.zipCode}</span>
            )}
          </div>
          <div className="form-group">
            <label htmlFor="country">Country *</label>
            <input
              type="text"
              id="country"
              value={details.country}
              onChange={handleChange("country")}
              className={errors.country ? "error" : ""}
            />
            {errors.country && (
              <span className="error-message">{errors.country}</span>
            )}
          </div>
        </div>

        <button type="submit" className="delivery-submit-btn">
          Continue to Payment
        </button>
      </form>
    </div>
  );
}
