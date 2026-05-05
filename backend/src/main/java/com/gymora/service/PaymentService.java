package com.gymora.service;

import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.dto.request.PaymentRequest;
import com.gymora.model.dto.response.PaymentResponse;
import com.gymora.model.entity.Customer;
import com.gymora.model.entity.Membership;
import com.gymora.model.entity.Payment;
import com.gymora.model.enums.PaymentStatus;
import com.gymora.repository.CustomerRepository;
import com.gymora.repository.MembershipRepository;
import com.gymora.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final MembershipRepository membershipRepository;
    private final CustomerRepository customerRepository;

    @Transactional
    public PaymentResponse recordPayment(PaymentRequest request) {
        Membership membership = membershipRepository.findById(request.getMembershipId())
                .orElseThrow(() -> new ResourceNotFoundException("Membership", "id", request.getMembershipId()));
        Customer customer = customerRepository.findById(request.getCustomerId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", request.getCustomerId()));

        Payment payment = Payment.builder()
                .membership(membership)
                .customer(customer)
                .amount(request.getAmount())
                .paymentMethod(request.getPaymentMethod())
                .transactionId(request.getTransactionId())
                .status(PaymentStatus.COMPLETED)
                .paidAt(LocalDateTime.now())
                .build();

        payment = paymentRepository.save(payment);
        return mapToResponse(payment);
    }

    public List<PaymentResponse> getCustomerPayments(Long customerId) {
        return paymentRepository.findByCustomerId(customerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<PaymentResponse> getGymPayments(Long gymId) {
        return paymentRepository.findByGymId(gymId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private PaymentResponse mapToResponse(Payment payment) {
        return PaymentResponse.builder()
                .id(payment.getId())
                .membershipId(payment.getMembership().getId())
                .planName(payment.getMembership().getPlanName())
                .customerId(payment.getCustomer().getId())
                .customerName(payment.getCustomer().getUser().getFullName())
                .amount(payment.getAmount())
                .paymentMethod(payment.getPaymentMethod())
                .status(payment.getStatus())
                .transactionId(payment.getTransactionId())
                .paidAt(payment.getPaidAt())
                .createdAt(payment.getCreatedAt())
                .build();
    }
}
