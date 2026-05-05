package com.gymora.controller;

import com.gymora.model.dto.request.MembershipRequest;
import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.MembershipResponse;
import com.gymora.service.MembershipService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/memberships")
@RequiredArgsConstructor
@Tag(name = "Memberships", description = "Membership management endpoints")
public class MembershipController {

    private final MembershipService membershipService;

    @PostMapping
    @PreAuthorize("hasRole('GYM_ADMIN')")
    @Operation(summary = "Create membership")
    public ResponseEntity<ApiResponse<MembershipResponse>> createMembership(
            @Valid @RequestBody MembershipRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Membership created",
                        membershipService.createMembership(request)));
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get customer memberships")
    public ResponseEntity<ApiResponse<List<MembershipResponse>>> getCustomerMemberships(
            @PathVariable Long customerId) {
        return ResponseEntity.ok(ApiResponse.success(
                membershipService.getCustomerMemberships(customerId)));
    }

    @GetMapping("/gym/{gymId}")
    @PreAuthorize("hasRole('GYM_ADMIN')")
    @Operation(summary = "List gym memberships")
    public ResponseEntity<ApiResponse<List<MembershipResponse>>> getGymMemberships(
            @PathVariable Long gymId) {
        return ResponseEntity.ok(ApiResponse.success(membershipService.getGymMemberships(gymId)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('GYM_ADMIN')")
    @Operation(summary = "Update membership")
    public ResponseEntity<ApiResponse<MembershipResponse>> updateMembership(
            @PathVariable Long id, @RequestBody MembershipRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Membership updated",
                membershipService.updateMembership(id, request)));
    }
}
